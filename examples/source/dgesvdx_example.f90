    Program dgesvdx_example

!     DGESVDX Example Program Text

!     Copyright 2017, Numerical Algorithms Group Ltd. http://www.nag.com

!     .. Use Statements ..
      Use lapack_interfaces, Only: dgesvdx
      Use lapack_precision, Only: dp
!     .. Implicit None Statement ..
      Implicit None
!     .. Parameters ..
      Integer, Parameter :: nin = 5, nout = 6
!     .. Local Scalars ..
      Real (Kind=dp) :: vl, vu
      Integer :: i, il, info, iu, lda, ldu, ldvt, lwork, m, n, ns
      Character (1) :: range
!     .. Local Arrays ..
      Real (Kind=dp), Allocatable :: a(:, :), a_copy(:, :), b(:), s(:), &
        u(:, :), vt(:, :), work(:)
      Real (Kind=dp) :: dummy(1, 1)
      Integer, Allocatable :: iwork(:)
!     .. Intrinsic Procedures ..
      Intrinsic :: nint
!     .. Executable Statements ..
      Write (nout, *) 'DGESVDX Example Program Results'
      Write (nout, *)
!     Skip heading in data file
      Read (nin, *)
      Read (nin, *) m, n
      lda = m
      ldu = m
      ldvt = n
      Allocate (a(lda,n), a_copy(m,n), s(n), vt(ldvt,n), u(ldu,m), b(m), &
        iwork(12*m))

!     Read the m by n matrix A from data file
      Read (nin, *)(a(i,1:n), i=1, m)

!     Read the right hand side of the linear system
      Read (nin, *) b(1:m)

!     Read range for selected singular values
      Read (nin, *) range

      If (range=='I' .Or. range=='i') Then
        Read (nin, *) il, iu
      Else If (range=='V' .Or. range=='v') Then
        Read (nin, *) vl, vu
      End If

      a_copy(1:m, 1:n) = a(1:m, 1:n)

!     Use routine workspace query to get optimal workspace.
      lwork = -1
      Call dgesvdx('V', 'V', range, m, n, a, lda, vl, vu, il, iu, ns, s, u, &
        ldu, vt, ldvt, dummy, lwork, iwork, info)

!     Make sure that there is enough workspace for block size nb.
      lwork = nint(dummy(1,1))
      Allocate (work(lwork))

!     Compute the singular values and left and right singular vectors
!     of A.

      Call dgesvdx('V', 'V', range, m, n, a, lda, vl, vu, il, iu, ns, s, u, &
        ldu, vt, ldvt, work, lwork, iwork, info)

      If (info/=0) Then
        Write (nout, 100) 'Failure in DGESVDX. INFO =', info
100     Format (1X, A, I4)
        Go To 120
      End If

!     Print the selected singular values of A

      Write (nout, *) 'Singular values of A:'
      Write (nout, 110) s(1:ns)
110   Format (1X, 4(3X,F11.4))

      Call compute_error_bounds(m, ns, s)

      If (m>n .And. ns==n) Then
!       Compute V*Inv(S)*U^T * b to get least squares solution.
        Call compute_least_squares(m, n, a_copy, m, u, ldu, vt, ldvt, s, b)
      End If

120   Continue

    Contains
      Subroutine compute_least_squares(m, n, a, lda, u, ldu, vt, ldvt, s, b)

!       .. Use Statements ..
        Use blas_interfaces, Only: dgemv, dnrm2
!       .. Implicit None Statement ..
        Implicit None
!       .. Scalar Arguments ..
        Integer, Intent (In) :: lda, ldu, ldvt, m, n
!       .. Array Arguments ..
        Real (Kind=dp), Intent (In) :: a(lda, n), s(n), u(ldu, m), vt(ldvt, n)
        Real (Kind=dp), Intent (Inout) :: b(m)
!       .. Local Scalars ..
        Real (Kind=dp) :: alpha, beta, norm
!       .. Local Arrays ..
        Real (Kind=dp), Allocatable :: x(:), y(:)
!       .. Intrinsic Procedures ..
        Intrinsic :: allocated
!       .. Executable Statements ..
        Allocate (x(n), y(n))

!       Compute V*Inv(S)*U^T * b to get least squares solution.

!       y = U^T b
        alpha = 1._dp
        beta = 0._dp
        Call dgemv('T', m, n, alpha, u, ldu, b, 1, beta, y, 1)

        y(1:n) = y(1:n)/s(1:n)

!       x = V y
        Call dgemv('T', n, n, alpha, vt, ldvt, y, 1, beta, x, 1)

        Write (nout, *)
        Write (nout, *) 'Least squares solution:'
        Write (nout, 100) x(1:n)

!       Find norm of residual ||b-Ax||.
        alpha = -1._dp
        beta = 1._dp
        Call dgemv('N', m, n, alpha, a, lda, x, 1, beta, b, 1)

        norm = dnrm2(m, b, 1)

        Write (nout, *)
        Write (nout, *) 'Norm of Residual:'
        Write (nout, 100) norm

        If (allocated(x)) Then
          Deallocate (x)
        End If
        If (allocated(y)) Then
          Deallocate (y)
        End If

100     Format (1X, 4(3X,F11.4))

      End Subroutine

      Subroutine compute_error_bounds(m, n, s)

!       Error estimates for singular values and vectors is computed
!       and printed here.

!       .. Use Statements ..
        Use lapack_interfaces, Only: ddisna
        Use lapack_precision, Only: dp
!       .. Implicit None Statement ..
        Implicit None
!       .. Scalar Arguments ..
        Integer, Intent (In) :: m, n
!       .. Array Arguments ..
        Real (Kind=dp), Intent (In) :: s(n)
!       .. Local Scalars ..
        Real (Kind=dp) :: eps, serrbd
        Integer :: i, info
!       .. Local Arrays ..
        Real (Kind=dp), Allocatable :: rcondu(:), rcondv(:), uerrbd(:), &
          verrbd(:)
!       .. Intrinsic Procedures ..
        Intrinsic :: epsilon
!       .. Executable Statements ..
        Allocate (rcondu(n), rcondv(n), uerrbd(n), verrbd(n))

!       Get the machine precision, EPS and compute the approximate
!       error bound for the computed singular values.  Note that for
!       the 2-norm, S(1) = norm(A)

        eps = epsilon(1.0E0_dp)
        serrbd = eps*s(1)

!       Call DDISNA to estimate reciprocal condition
!       numbers for the singular vectors

        Call ddisna('Left', m, n, s, rcondu, info)
        Call ddisna('Right', m, n, s, rcondv, info)

!       Compute the error estimates for the singular vectors

        Do i = 1, n
          uerrbd(i) = serrbd/rcondu(i)
          verrbd(i) = serrbd/rcondv(i)
        End Do

!       Print the approximate error bounds for the singular values
!       and vectors

        Write (nout, *)
        Write (nout, *) 'Estimates given as multiples of machine precision'
        Write (nout, *) 'Error estimate for the singular values'
        Write (nout, 100) nint(serrbd/epsilon(1.0E0_dp))
        Write (nout, *)
        Write (nout, *) 'Error estimates for the left singular vectors'
        Write (nout, 100) nint(uerrbd(1:n)/epsilon(1.0E0_dp))
        Write (nout, *)
        Write (nout, *) 'Error estimates for the right singular vectors'
        Write (nout, 100) nint(verrbd(1:n)/epsilon(1.0E0_dp))

100     Format (4X, 6I11)

      End Subroutine

    End Program
