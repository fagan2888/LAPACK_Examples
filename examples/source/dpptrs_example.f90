    Program dpptrs_example

!     DPPTRS Example Program Text

!     Copyright 2017, Numerical Algorithms Group Ltd. http://www.nag.com

!     .. Use Statements ..
      Use lapack_example_aux, Only: nagf_file_print_matrix_real_gen
      Use lapack_interfaces, Only: dpptrf, dpptrs
      Use lapack_precision, Only: dp
!     .. Implicit None Statement ..
      Implicit None
!     .. Parameters ..
      Integer, Parameter :: nin = 5, nout = 6
!     .. Local Scalars ..
      Integer :: i, ifail, info, j, ldb, n, nrhs
      Character (1) :: uplo
!     .. Local Arrays ..
      Real (Kind=dp), Allocatable :: ap(:), b(:, :)
!     .. Executable Statements ..
      Write (nout, *) 'DPPTRS Example Program Results'
!     Skip heading in data file
      Read (nin, *)
      Read (nin, *) n, nrhs
      ldb = n
      Allocate (ap(n*(n+1)/2), b(ldb,nrhs))

!     Read A and B from data file

      Read (nin, *) uplo
      If (uplo=='U') Then
        Read (nin, *)((ap(i+j*(j-1)/2),j=i,n), i=1, n)
      Else If (uplo=='L') Then
        Read (nin, *)((ap(i+(2*n-j)*(j-1)/2),j=1,i), i=1, n)
      End If
      Read (nin, *)(b(i,1:nrhs), i=1, n)

!     Factorize A
      Call dpptrf(uplo, n, ap, info)

      Write (nout, *)
      Flush (nout)
      If (info==0) Then

!       Compute solution
        Call dpptrs(uplo, n, nrhs, ap, b, ldb, info)

!       Print solution

!       ifail: behaviour on error exit
!              =0 for hard exit, =1 for quiet-soft, =-1 for noisy-soft
        ifail = 0
        Call nagf_file_print_matrix_real_gen('General', ' ', n, nrhs, b, ldb, &
          'Solution(s)', ifail)

      Else
        Write (nout, *) 'A is not positive definite'
      End If

    End Program
