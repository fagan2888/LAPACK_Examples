    Program dsysv_example

!     DSYSV Example Program Text

!     Copyright 2017, Numerical Algorithms Group Ltd. http://www.nag.com

!     .. Use Statements ..
      Use lapack_example_aux, Only: nagf_file_print_matrix_real_gen
      Use lapack_interfaces, Only: dsysv
      Use lapack_precision, Only: dp
!     .. Implicit None Statement ..
      Implicit None
!     .. Parameters ..
      Integer, Parameter :: nb = 64, nin = 5, nout = 6
!     .. Local Scalars ..
      Integer :: i, ifail, info, lda, lwork, n
!     .. Local Arrays ..
      Real (Kind=dp), Allocatable :: a(:, :), b(:), work(:)
      Integer, Allocatable :: ipiv(:)
!     .. Executable Statements ..
      Write (nout, *) 'DSYSV Example Program Results'
      Write (nout, *)
!     Skip heading in data file
      Read (nin, *)
      Read (nin, *) n
      lda = n
      lwork = nb*n
      Allocate (a(lda,n), b(n), work(lwork), ipiv(n))

!     Read the upper triangular part of the matrix A from data file

      Read (nin, *)(a(i,i:n), i=1, n)

!     Read b from data file

      Read (nin, *) b(1:n)

!     Solve the equations Ax = b for x
      Call dsysv('Upper', n, 1, a, lda, ipiv, b, n, work, lwork, info)

      If (info==0) Then

!       Print solution

        Write (nout, *) 'Solution'
        Write (nout, 100) b(1:n)

!       Print details of factorization

        Write (nout, *)
        Flush (nout)

!       ifail: behaviour on error exit
!              =0 for hard exit, =1 for quiet-soft, =-1 for noisy-soft
        ifail = 0
        Call nagf_file_print_matrix_real_gen('Upper', 'Non-unit diagonal', n, &
          n, a, lda, 'Details of the factorization', ifail)

!       Print pivot indices

        Write (nout, *)
        Write (nout, *) 'Pivot indices'
        Write (nout, 110) ipiv(1:n)

      Else
        Write (nout, 120) 'The diagonal block ', info, ' of D is zero'
      End If

100   Format ((3X,7F11.4))
110   Format (1X, 7I11)
120   Format (1X, A, I3, A)
    End Program
