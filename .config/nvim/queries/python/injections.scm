;; extends

(class_definition
  body: (
    (block
      (expression_statement
        (assignment
          left: (identifier) @_class_var_name
          right: (
              (string (string_content) @injection.content)
          )
        )
      )
    )
  )
  (#match? @_class_var_name "^(DEFAULT_)?CSS$")
  (#set! injection.language "css")
)
