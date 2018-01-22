    Program dptsv_example

!     DPTSV Example Program Text

!     Copyright 2017, Numerical Algorithms Group Ltd. http://www.nag.com

!     .. Use Statements ..
      Use lapack_interfaces, Only: dptsv
      Use lapack_precision, Only: dp
!     .. Implicit None Statement ..
      Implicit None
!     .. Parameters ..
      Integer, Parameter :: nin = 5, nout = 6
!     .. Local Scalars ..
      Integer :: info, n
!     .. Local Arrays ..
      Real (Kind=dp), Allocatable :: b(:), d(:), e(:)
!     .. Executable Statements ..
      Write (nout, *) 'DPTSV Example Program Results'
      Write (nout, *)
!     Skip heading in data file
      Read (nin, *)
      Read (nin, *) n

      Allocate (b(n), d(n), e(n-1))

!     Read the lower bidiagonal part of the tridiagonal matrix A and
!     the right hand side b from data file

      Read (nin, *) d(1:n)
      Read (nin, *) e(1:n-1)
      Read (nin, *) b(1:n)

!     Solve the equations Ax = b for x

      Call dptsv(n, 1, d, e, b, n, info)

      If (info==0) Then

!       Print solution

        Write (nout, *) 'Solution'
        Write (nout, 100) b(1:n)

!       Print details of factorization

        Write (nout, *)
        Write (nout, *) 'Diagonal elements of the diagonal matrix D'
        Write (nout, 100) d(1:n)
        Write (nout, *)
        Write (nout, *) 'Subdiagonal elements of the Cholesky factor L'
        Write (nout, 100) e(1:n-1)

      Else
        Write (nout, 110) 'The leading minor of order ', info, &
          ' is not positive definite'
      End If

100   Format (1X, 7F11.4)
110   Format (1X, A, I3, A)
    End Program
