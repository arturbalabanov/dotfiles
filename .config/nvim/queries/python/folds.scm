;; Fold all decorated functions
(
  decorated_definition
  (function_definition)
) @fold

;; Fold all non-decorated functions (split is necessary to avoid double folding of decorated functions)
(
  (function_definition) @_fn
  (#not-has-parent? @_fn decorated_definition)
) @fold


;; Fold all decorated classes
(
  decorated_definition
  (class_definition)
) @fold

;; Fold all non-decorated classes (split is necessary to avoid double folding of decorated classes)
(
  (class_definition) @_fn
  (#not-has-parent? @_fn decorated_definition)
) @fold

;; fold all import statements
[
  (future_import_statement)
  (import_statement)
  (import_from_statement)
  ((import_from_statement) (comment))
  ((import_statement) (comment))
  ((future_import_statement) (comment))
]+ @fold

;; fold all import statements
;;
;; stolen from: https://github.com/wookayin/dotfiles/blob/af9b864ac35b65e8aeeb68e863dfe61844d8f693/nvim/after/queries/python/folds.scm 

; (module
;   . (comment)*
;   . (expression_statement)?   ; an optional docstring at the very first top
;   . (comment)*
;   ; Capture a region of consecutive import statements to fold
;   . [(import_statement) (import_from_statement) (future_import_statement)] @_start
;   . [(import_statement) (import_from_statement) (future_import_statement) (comment)]*
;   . [(import_statement) (import_from_statement) (future_import_statement)]+ @_end
;   ; ... until the first non-import node.
;   . (_)  @_non_import1  (#not-kind-eq? @_non_import1  import_statement import_from_statement future_import_statement)
;   ; However, don't match if followed by another import statement,
;   ; to ensure the capture group is maximial and avoid nested foldings.
;   . (_)? @_non_import2  (#not-kind-eq? @_non_import2  import_statement import_from_statement future_import_statement)
;
;   (#make-range! "fold" @_start @_end)
; )
