    Program dgelss_example

!     DGELSS Example Program Text

!     Copyright 2017, Numerical Algorithms Group Ltd. http://www.nag.com

!     .. Use Statements ..
      Use blas_interfaces, Only: dnrm2
      Use lapack_interfaces, Only: dgelss
      Use lapack_precision, Only: dp
!     .. Implicit None Statement ..
      Implicit None
!     .. Parameters ..
      Integer, Parameter :: nb = 64, nin = 5, nout = 6
!     .. Local Scalars ..
      Real (Kind=dp) :: rcond, rnorm
      Integer :: i, info, lda, lwork, m, n, rank
!     .. Local Arrays ..
      Real (Kind=dp), Allocatable :: a(:, :), b(:), s(:), work(:)
!     .. Executable Statements ..
      Write (nout, *) 'DGELSS Example Program Results'
      Write (nout, *)
!     Skip heading in data file
      Read (nin, *)
      Read (nin, *) m, n
      lda = m
      lwork = 3*n + nb*(m+n)
      Allocate (a(lda,n), b(m), s(n), work(lwork))

!     Read A and B from data file

      Read (nin, *)(a(i,1:n), i=1, m)
      Read (nin, *) b(1:m)

!     Choose RCOND to reflect the relative accuracy of the input data

      rcond = 0.01_dp

!     Solve the least squares problem min( norm2(b - Ax) ) for the x
!     of minimum norm.

      Call dgelss(m, n, 1, a, lda, b, m, s, rcond, rank, work, lwork, info)

      If (info==0) Then

!       Print solution

        Write (nout, *) 'Least squares solution'
        Write (nout, 100) b(1:n)

!       Print the effective rank of A

        Write (nout, *)
        Write (nout, *) 'Tolerance used to estimate the rank of A'
        Write (nout, 110) rcond
        Write (nout, *) 'Estimated rank of A'
        Write (nout, 120) rank

!       Print singular values of A

        Write (nout, *)
        Write (nout, *) 'Singular values of A'
        Write (nout, 100) s(1:n)

!       Compute and print estimate of the square root of the
!       residual sum of squares

        If (rank==n) Then
          rnorm = dnrm2(m-n, b(n+1), 1)
          Write (nout, *)
          Write (nout, *) 'Square root of the residual sum of squares'
          Write (nout, 110) rnorm
        End If
      Else
        Write (nout, *) 'The SVD algorithm failed to converge'
      End If

100   Format (1X, 7F11.4)
110   Format (3X, 1P, E11.2)
120   Format (1X, I6)
    End Program
