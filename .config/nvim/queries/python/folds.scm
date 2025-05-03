;; TODO: there is overlap between this and the function / class definitions bellow
;;       what i really want is to fold either (!) non-decorated functions OR decorated
;;       functions together with their decorator, same with classes

;; Fold all function definitions (with an without decorators)
[
  (
   module
   (function_definition) @fold
  )
  (decorated_definition
    (function_definition)
  ) @fold
]

;; Fold all class definitions (with an without decorators)
[
  (
   module
   (class_definition) @fold
  )
  (decorated_definition
    (class_definition)
  ) @fold
]

;; fold all import statements
;;
;; stolen from: https://github.com/wookayin/dotfiles/blob/af9b864ac35b65e8aeeb68e863dfe61844d8f693/nvim/after/queries/python/folds.scm 

(module
  . (comment)*
  . (expression_statement)?   ; an optional docstring at the very first top
  . (comment)*
  ; Capture a region of consecutive import statements to fold
  . [(import_statement) (import_from_statement) (future_import_statement)] @_start
  . [(import_statement) (import_from_statement) (future_import_statement) (comment)]*
  . [(import_statement) (import_from_statement) (future_import_statement)]+ @_end
  ; ... until the first non-import node.
  . (_)  @_non_import1  (#not-kind-eq? @_non_import1  import_statement import_from_statement future_import_statement)
  ; However, don't match if followed by another import statement,
  ; to ensure the capture group is maximial and avoid nested foldings.
  . (_)? @_non_import2  (#not-kind-eq? @_non_import2  import_statement import_from_statement future_import_statement)

  (#make-range! "fold" @_start @_end)
)
