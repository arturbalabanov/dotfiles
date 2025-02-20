;; extends

(decorated_definition
   (decorator
     [
      (call
       function: (
         attribute
            object: (identifier) @_obj_name
            attribute: (identifier) @_dec_name))
     (attribute
        object: (identifier) @_obj_name
        attribute: (identifier) @_dec_name)
    (#eq? @_obj_name "pytest")
    (#eq? @_dec_name "fixture")
     ]
     )
 definition: (
   function_definition) @pytest_fixture
 )
