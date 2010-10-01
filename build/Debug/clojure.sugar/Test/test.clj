; this is a comment 

(println '1 ('hello 'world))

(comment (defn perfect? [n]
 ()(= n (sum (divisors n)))))

;; strings 
(println "\"hello world;\"\n")
(println "\"\thello world\"\n\6") ; \6 is an invalid escape
(println '"\"\thello world\"\n\6") ; \6 is an invalid escape
(println ''"'hey" ''(println hey))

;; numbers and numbers w/ quotes
(comment (println) 1)
(println '1)
(println 5.0)
(println '5.0)
(println 5e100)
(println '5e100)
(println 5.0e100)
(println '5.0e100)
(println 345 5 5.6 1e100)

(println (+ 1 
           (+ 5 
             (* 8 
                4)))) ; nested s-expression
                  
(println (+ 1 (- 5 4))))     ; nested s-expression with too many closing )

;; quoted expressions
(println '(println '(println hello))) 
(println '(println '(println hello)) ''1)

;; vector
(println [1 2 (* 3 4)])
(println ['1 2 3])

;; set
(println #{1 2 3})
(println #{'1 2 3})

;; hash map
(println {:key "value"})

;; defn
(defn "prints hello world" hello-world [x y z] (println 'hello-world))

;; fn
(fn [x] (println x))

;; def
(def x 4)

;; sample program
(ns perfect-number.core)

;;; Compute the divisors of n
(defn divisors [n]
  (filter #(= (rem n %) 0) (range 1 (inc (/ n 2 )))))

(defn sum [s]  ; this is a comment
  (reduce + s))

(defn perfect? [n]
  (= n (sum (divisors n))))

(defn perfect-numbers []
  (filter perfect? (nnext (range))))

(println (take 1 (perfect-numbers)))

;; if statement
(if (= (f x) 4)
    (top-level x)
    (g x))
; end

; this is a comment 

(println '1)

(comment (defn perfect? [n]
 ()(= n (sum (divisors n)))))

;; strings 
(println "\"hello world;\"\n")
(println "\"\thello world\"\n\6") ; \6 is an invalid escape
(println '"\"\thello world\"\n\6") ; \6 is an invalid escape
(println ''"'hey" ''(println hey))

;; numbers and numbers w/ quotes
(comment (println) 1)
(println '1)
(println 5.0)
(println '5.0)
(println 5e100)
(println '5e100)
(println 5.0e100)
(println '5.0e100)
(println 345 5 5.6 1e100)

(println (+ 1 
           (+ 5 
             (* 8 
                4)))) ; nested s-expression
                  
(println (+ 1 (- 5 4))))     ; nested s-expression with too many closing )

;; quoted expressions
(println '(println '(println hello))) 
(println '(println '(println hello)) ''1)

;; vector
(println [1 2 (* 3 4)])
(println ['1 2 3])

;; set
(println #{1 2 3})
(println #{'1 2 3})

;; hash map
(println {:key "value"})

;; defn
(defn "prints hello world" hello-world [x y z] (println 'hello-world))

;; fn
(fn [x] (println x))

;; def
(def x 4)

;; sample program
(ns perfect-number.core)

;;; Compute the divisors of n
(defn divisors [n]
  (filter #(= (rem n %) 0) (range 1 (inc (/ n 2 )))))

(defn sum [s]  ; this is a comment
  (reduce + s))

(defn perfect? [n]
  (= n (sum (divisors n))))

(defn perfect-numbers []
  (filter perfect? (nnext (range))))

(println (take 1 (perfect-numbers)))

;; if statement
(if (= (f x) 4)
    (top-level x)
    (g x))
; end




; this is a comment 

(println '1)

(comment (defn perfect? [n]
 ()(= n (sum (divisors n)))))

;; strings 
(println "\"hello world;\"\n")
(println "\"\thello world\"\n\6") ; \6 is an invalid escape
(println '"\"\thello world\"\n\6") ; \6 is an invalid escape
(println ''"'hey" ''(println hey))

;; numbers and numbers w/ quotes
(comment (println) 1)
(println '1)
(println 5.0)
(println '5.0)
(println 5e100)
(println '5e100)
(println 5.0e100)
(println '5.0e100)
(println 345 5 5.6 1e100)

(println (+ 1 
           (+ 5 
             (* 8 
                4)))) ; nested s-expression
                  
(println (+ 1 (- 5 4))))     ; nested s-expression with too many closing )

;; quoted expressions
(println '(println '(println hello))) 
(println '(println '(println hello)) ''1)

;; vector
(println [1 2 (* 3 4)])
(println ['1 2 3])

;; set
(println #{1 2 3})
(println #{'1 2 3})

;; hash map
(println {:key "value"})

;; defn
(defn "prints hello world" hello-world [x y z] (println 'hello-world))

;; fn
(fn [x] (println x))

;; def
(def x 4)

;; sample program
(ns perfect-number.core)

;;; Compute the divisors of n
(defn divisors [n]
  (filter #(= (rem n %) 0) (range 1 (inc (/ n 2 )))))

(defn sum [s]  ; this is a comment
  (reduce + s))

(defn perfect? [n]
  (= n (sum (divisors n))))

(defn perfect-numbers []
  (filter perfect? (nnext (range))))

(println (take 1 (perfect-numbers)))

;; if statement
(if (= (f x) 4)
    (top-level x)
    (g x))
; end




; this is a comment 

(println '1)

(comment (defn perfect? [n]
 ()(= n (sum (divisors n)))))

;; strings 
(println "\"hello world;\"\n")
(println "\"\thello world\"\n\6") ; \6 is an invalid escape
(println '"\"\thello world\"\n\6") ; \6 is an invalid escape
(println ''"'hey" ''(println hey))

;; numbers and numbers w/ quotes
(comment (println) 1)
(println '1)
(println 5.0)
(println '5.0)
(println 5e100)
(println '5e100)
(println 5.0e100)
(println '5.0e100)
(println 345 5 5.6 1e100)

(println (+ 1 
           (+ 5 
             (* 8 
                4)))) ; nested s-expression
                  
(println (+ 1 (- 5 4))))     ; nested s-expression with too many closing )

;; quoted expressions
(println '(println '(println hello))) 
(println '(println '(println hello)) ''1)

;; vector
(println [1 2 (* 3 4)])
(println ['1 2 3])

;; set
(println #{1 2 3})
(println #{'1 2 3})

;; hash map
(println {:key "value"})

;; defn
(defn "prints hello world" hello-world [x y z] (println 'hello-world))

;; fn
(fn [x] (println x))

;; def
(def x 4)  

;; sample program
(ns perfect-number.core)

;;; Compute the divisors of n
(defn divisors [n]
  (filter #(= (rem n %) 0) (range 1 (inc (/ n 2 )))))

(defn sum [s]  ; this is a comment
  (reduce + s))

(defn perfect? [n]
  (= n (sum (divisors n))))

(defn perfect-numbers []
  (filter perfect? (nnext (range))))

(println (take 1 (perfect-numbers)))

;; if statement
(if (= (f x) 4)
    (top-level x)
    (g x))
; end




; this is a comment 

(println '1 ('hello 'world))

(comment (defn perfect? [n]
 ()(= n (sum (divisors n)))))

;; strings 
(println "\"hello world;\"\n")
(println "\"\thello world\"\n\6") ; \6 is an invalid escape
(println '"\"\thello world\"\n\6") ; \6 is an invalid escape
(println ''"'hey" ''(println hey))

;; numbers and numbers w/ quotes
(comment (println) 1)
(println '1)
(println 5.0)
(println '5.0)
(println 5e100)
(println '5e100)
(println 5.0e100)
(println '5.0e100)
(println 345 5 5.6 1e100)

(println (+ 1 
           (+ 5 
             (* 8 
                4)))) ; nested s-expression
                  
(println (+ 1 (- 5 4))))     ; nested s-expression with too many closing )

;; quoted expressions
(println '(println '(println hello))) 
(println '(println '(println hello)) ''1)

;; vector
(println [1 2 (* 3 4)])
(println ['1 2 3])

;; set
(println #{1 2 3})
(println #{'1 2 3})

;; hash map
(println {:key "value"})

;; defn
(defn "prints hello world" hello-world [x y z] (println 'hello-world))

;; fn
(fn [x] (println x))

;; def
(def x 4)

;; sample program
(ns perfect-number.core)

;;; Compute the divisors of n
(defn divisors [n]
  (filter #(= (rem n %) 0) (range 1 (inc (/ n 2 )))))

(defn sum [s]  ; this is a comment
  (reduce + s))

(defn perfect? [n]
  (= n (sum (divisors n))))

(defn perfect-numbers []
  (filter perfect? (nnext (range))))

(println (take 1 (perfect-numbers)))

;; if statement
(if (= (f x) 4)
    (top-level x)
    (g x))
; end

; this is a comment 

(println '1)

(comment (defn perfect? [n]
 ()(= n (sum (divisors n)))))

;; strings 
(println "\"hello world;\"\n")
(println "\"\thello world\"\n\6") ; \6 is an invalid escape
(println '"\"\thello world\"\n\6") ; \6 is an invalid escape
(println ''"'hey" ''(println hey))

;; numbers and numbers w/ quotes
(comment (println) 1)
(println '1)
(println 5.0)
(println '5.0)
(println 5e100)
(println '5e100)
(println 5.0e100)
(println '5.0e100)
(println 345 5 5.6 1e100)

(println (+ 1 
           (+ 5 
             (* 8 
                4)))) ; nested s-expression
                  
(println (+ 1 (- 5 4))))     ; nested s-expression with too many closing )

;; quoted expressions
(println '(println '(println hello))) 
(println '(println '(println hello)) ''1)

;; vector
(println [1 2 (* 3 4)])
(println ['1 2 3])

;; set
(println #{1 2 3})
(println #{'1 2 3})

;; hash map
(println {:key "value"})

;; defn
(defn "prints hello world" hello-world [x y z] (println 'hello-world))

;; fn
(fn [x] (println x))

;; def
(def x 4)

;; sample program
(ns perfect-number.core)

;;; Compute the divisors of n
(defn divisors [n]
  (filter #(= (rem n %) 0) (range 1 (inc (/ n 2 )))))

(defn sum [s]  ; this is a comment
  (reduce + s))

(defn perfect? [n]
  (= n (sum (divisors n))))

(defn perfect-numbers []
  (filter perfect? (nnext (range))))

(println (take 1 (perfect-numbers)))

;; if statement
(if (= (f x) 4)
    (top-level x)
    (g x))
; end




; this is a comment 

(println '1)

(comment (defn perfect? [n]
 ()(= n (sum (divisors n)))))

;; strings 
(println "\"hello world;\"\n")
(println "\"\thello world\"\n\6") ; \6 is an invalid escape
(println '"\"\thello world\"\n\6") ; \6 is an invalid escape
(println ''"'hey" ''(println hey))

;; numbers and numbers w/ quotes
(comment (println) 1)
(println '1)
(println 5.0)
(println '5.0)
(println 5e100)
(println '5e100)
(println 5.0e100)
(println '5.0e100)
(println 345 5 5.6 1e100)

(println (+ 1 
           (+ 5 
             (* 8 
                4)))) ; nested s-expression
                  
(println (+ 1 (- 5 4))))     ; nested s-expression with too many closing )

;; quoted expressions
(println '(println '(println hello))) 
(println '(println '(println hello)) ''1)

;; vector
(println [1 2 (* 3 4)])
(println ['1 2 3])

;; set
(println #{1 2 3})
(println #{'1 2 3})

;; hash map
(println {:key "value"})

;; defn
(defn "prints hello world" hello-world [x y z] (println 'hello-world))

;; fn
(fn [x] (println x))

;; def
(def x 4)

;; sample program
(ns perfect-number.core)

;;; Compute the divisors of n
(defn divisors [n]
  (filter #(= (rem n %) 0) (range 1 (inc (/ n 2 )))))

(defn sum [s]  ; this is a comment
  (reduce + s))

(defn perfect? [n]
  (= n (sum (divisors n))))

(defn perfect-numbers []
  (filter perfect? (nnext (range))))

(println (take 1 (perfect-numbers)))

;; if statement
(if (= (f x) 4)
    (top-level x)
    (g x))
; end




; this is a comment 

(println '1)

(comment (defn perfect? [n]
 ()(= n (sum (divisors n)))))

;; strings 
(println "\"hello world;\"\n")
(println "\"\thello world\"\n\6") ; \6 is an invalid escape
(println '"\"\thello world\"\n\6") ; \6 is an invalid escape
(println ''"'hey" ''(println hey))

;; numbers and numbers w/ quotes
(comment (println) 1)
(println '1)
(println 5.0)
(println '5.0)
(println 5e100)
(println '5e100)
(println 5.0e100)
(println '5.0e100)
(println 345 5 5.6 1e100)

(println (+ 1 
           (+ 5 
             (* 8 
                4)))) ; nested s-expression
                  
(println (+ 1 (- 5 4))))     ; nested s-expression with too many closing )

;; quoted expressions
(println '(println '(println hello))) 
(println '(println '(println hello)) ''1)

;; vector
(println [1 2 (* 3 4)])
(println ['1 2 3])

;; set
(println #{1 2 3})
(println #{'1 2 3})

;; hash map
(println {:key "value"})

;; defn
(defn "prints hello world" hello-world [x y z] (println 'hello-world))

;; fn
(fn [x] (println x))

;; def
(def x 4)  

;; sample program
(ns perfect-number.core)

;;; Compute the divisors of n
(defn divisors [n]
  (filter #(= (rem n %) 0) (range 1 (inc (/ n 2 )))))

(defn sum [s]  ; this is a comment
  (reduce + s))

(defn perfect? [n]
  (= n (sum (divisors n))))

(defn perfect-numbers []
  (filter perfect? (nnext (range))))

(println (take 1 (perfect-numbers)))

;; if statement
(if (= (f x) 4)
    (top-level x)
    (g x))
; end












