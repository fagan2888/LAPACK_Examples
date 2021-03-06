    Program ztgsyl_example

!     ZTGSYL Example Program Text

!     Copyright (c) 2018, Numerical Algorithms Group (NAG Ltd.)
!     For licence see
!       https://github.com/numericalalgorithmsgroup/LAPACK_Examples/blob/master/LICENCE.md

!     .. Use Statements ..
      Use lapack_example_aux, Only: nagf_file_print_matrix_complex_gen_comp
      Use lapack_interfaces, Only: ztgsyl
      Use lapack_precision, Only: dp
!     .. Implicit None Statement ..
      Implicit None
!     .. Parameters ..
      Integer, Parameter :: nin = 5, nout = 6
!     .. Local Scalars ..
      Real (Kind=dp) :: dif, scale
      Integer :: i, ifail, ijob, info, lda, ldb, ldc, ldd, lde, ldf, lwork, m, &
        n
!     .. Local Arrays ..
      Complex (Kind=dp), Allocatable :: a(:, :), b(:, :), c(:, :), d(:, :), &
        e(:, :), f(:, :), work(:)
      Integer, Allocatable :: iwork(:)
      Character (1) :: clabs(1), rlabs(1)
!     .. Executable Statements ..
      Write (nout, *) 'ZTGSYL Example Program Results'
      Write (nout, *)
      Flush (nout)
!     Skip heading in data file
      Read (nin, *)
      Read (nin, *) m, n
      lda = m
      ldb = n
      ldc = m
      ldd = m
      lde = n
      ldf = m
      lwork = 1
      Allocate (a(lda,m), b(ldb,n), c(ldc,n), d(ldd,m), e(lde,n), f(ldf,n), &
        work(lwork), iwork(m+n+2))

!     Read A, B, D, E, C and F from data file

      Read (nin, *)(a(i,1:m), i=1, m)
      Read (nin, *)(b(i,1:n), i=1, n)
      Read (nin, *)(d(i,1:m), i=1, m)
      Read (nin, *)(e(i,1:n), i=1, n)
      Read (nin, *)(c(i,1:n), i=1, m)
      Read (nin, *)(f(i,1:n), i=1, m)

!     Solve the Sylvester equations
!         A*R - L*B = scale*C and D*R - L*E = scale*F
!     for R and L.

      ijob = 0

      Call ztgsyl('No transpose', ijob, m, n, a, lda, b, ldb, c, ldc, d, ldd, &
        e, lde, f, ldf, scale, dif, work, lwork, iwork, info)

      If (info>=1) Then
        Write (nout, 100)
        Write (nout, *)
        Flush (nout)
      End If

!     Print the solution matrices R and L

!     ifail: behaviour on error exit
!             =0 for hard exit, =1 for quiet-soft, =-1 for noisy-soft
      ifail = 0
      Call nagf_file_print_matrix_complex_gen_comp('General', ' ', m, n, c, &
        ldc, 'Bracketed', 'F7.4', 'Solution matrix R', 'Integer', rlabs, &
        'Integer', clabs, 80, 0, ifail)

      Write (nout, *)
      Flush (nout)

      ifail = 0
      Call nagf_file_print_matrix_complex_gen_comp('General', ' ', m, n, f, &
        ldf, 'Bracketed', 'F7.4', 'Solution matrix L', 'Integer', rlabs, &
        'Integer', clabs, 80, 0, ifail)

      Write (nout, *)
      Write (nout, 110) 'SCALE = ', scale

100   Format (/, ' (A,D) and (B,E) have common or very close eigenval', &
        'ues.', /, ' Perturbed values were used to solve the equations')
110   Format (1X, A, 1P, E10.2)
    End Program
