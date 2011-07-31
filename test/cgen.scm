;;
;; gauche.cgen.* tests
;;

(use gauche.test)
(use gauche.parameter)
(use file.util)
(use gauche.cgen)

(test-start "gauche.cgen.*")

;;====================================================================
(test-section "gauche.cgen.unit")
(use gauche.cgen.unit)
(test-module 'gauche.cgen.unit)

;; simple things
(sys-unlink "tmp.o.c")
(test* "cgen.unit basic stuff"
       "/* Generated by gauche.cgen */
static void foo(void);
static void foo() { ... }
void Scm__Init_tmp_2eo(void)
{
foo();
#if ((defined FOO))||((defined BAR))
init_foo_bar();
#endif /* ((defined FOO))||((defined BAR)) */
#if ((>= BAR_VERSION 3))&&((== FOO_VERSION 2))
#if ((defined FOO))||((defined BAR))
some_trick();
#endif /* ((>= BAR_VERSION 3))&&((== FOO_VERSION 2)) */
#endif /* ((defined FOO))||((defined BAR)) */
}
"
       (parameterize ([cgen-current-unit (make <cgen-unit> :name "tmp.o")])
         (cgen-init "foo();")
         (cgen-decl "static void foo(void);")
         (cgen-body "static void foo() { ... }")
         (cgen-with-cpp-condition '(or (defined FOO) (defined BAR))
           (cgen-init "init_foo_bar();")
           (cgen-with-cpp-condition '(and (>= BAR_VERSION 3) (== FOO_VERSION 2))
             (cgen-init "some_trick();")))
         (cgen-emit-c (cgen-current-unit))
         (begin0 (file->string "tmp.o.c")
           (sys-unlink "tmp.o.c"))))

;;====================================================================
(test-section "gauche.cgen.literal")
(use gauche.cgen.type)
(test-module 'gauche.cgen.literal)

;;====================================================================
(test-section "gauche.cgen.type")
(use gauche.cgen.type)
(test-module 'gauche.cgen.type)

;;====================================================================
(test-section "gauche.cgen.cise")
(use gauche.cgen.cise)
(test-module 'gauche.cgen.cise)

(let ()
  (define (t in out)
    (test* (format "canonicalize-vardecl ~s" in) out
           ((with-module gauche.cgen.cise canonicalize-vardecl) in)))

  (t '(a b c) '((a :: ScmObj) (b :: ScmObj) (c :: ScmObj)))
  (t '((a) (b) (c)) '((a) (b) (c)))
  (t '(a::x b::y (c::z)) '((a :: x) (b :: y) (c :: z)))
  (t '(a :: x b :: y (c :: z)) '((a :: x) (b :: y) (c :: z)))
  (t '(a:: x b ::y (c:: z)) '((a :: x) (b :: y) (c :: z)))
  (t '(a::(x y z) b::p) '((a :: (x y z)) (b :: p)))

  (t '((a::x init) (b::(x) init) (c :: x init))
     '((a :: x init) (b :: (x) init) (c :: x init)))
  (t '((a init) (b init) (c init))
     '((a init) (b init) (c init)))
  )

;;====================================================================
(test-section "gauche.cgen.stub")
(use gauche.cgen.stub)
(test-module 'gauche.cgen.stub)

;;====================================================================
(test-section "gauche.cgen.precomp")
(use gauche.cgen.precomp)
(test-module 'gauche.cgen.precomp)

;;====================================================================
(test-section "gauche.cgen")
(use gauche.cgen)
(test-module 'gauche.cgen)

(test-end)
