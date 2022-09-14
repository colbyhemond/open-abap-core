CLASS kernel_create_data_handle DEFINITION PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS call
      IMPORTING
        handle TYPE REF TO cl_abap_datadescr
      CHANGING
        dref   TYPE REF TO any.
  PRIVATE SECTION.
    CLASS-METHODS elem
      IMPORTING
        handle TYPE REF TO cl_abap_datadescr
      CHANGING
        dref   TYPE REF TO any.
    CLASS-METHODS struct
      IMPORTING
        handle TYPE REF TO cl_abap_datadescr
      CHANGING
        dref   TYPE REF TO any.
    CLASS-METHODS table
      IMPORTING
        handle TYPE REF TO cl_abap_datadescr
      CHANGING
        dref   TYPE REF TO any.
ENDCLASS.

CLASS kernel_create_data_handle IMPLEMENTATION.

  METHOD call.
    ASSERT handle IS BOUND.

    CASE handle->kind.
      WHEN cl_abap_typedescr=>kind_elem.
        elem( EXPORTING handle = handle
              CHANGING dref = dref ).
      WHEN cl_abap_typedescr=>kind_struct.
        struct( EXPORTING handle = handle
                CHANGING dref = dref ).
      WHEN cl_abap_typedescr=>kind_table.
        table( EXPORTING handle = handle
               CHANGING dref = dref ).
      WHEN OTHERS.
        WRITE '@KERNEL console.dir(handle);'.
        ASSERT 1 = 'todo'.
    ENDCASE.
  ENDMETHOD.

  METHOD struct.
    DATA lo_struct     TYPE REF TO cl_abap_structdescr.
    DATA lt_components TYPE cl_abap_structdescr=>component_table.
    DATA ls_component  LIKE LINE OF lt_components.
    DATA field         TYPE REF TO data.

    lo_struct ?= handle.
    lt_components = lo_struct->get_components( ).
    WRITE '@KERNEL let obj = {};'.
    LOOP AT lt_components INTO ls_component.
*      WRITE '@KERNEL console.dir(ls_component.get().name);'.
      call(
        EXPORTING
          handle = lo_struct->get_component_type( ls_component-name )
        CHANGING
          dref   = field ).
      WRITE '@KERNEL obj[ls_component.get().name.get().toLowerCase()] = field;'.
    ENDLOOP.
    WRITE '@KERNEL dref.assign(new abap.types.Structure(obj));'.
  ENDMETHOD.

  METHOD table.
    DATA lo_table TYPE REF TO cl_abap_tabledescr.
    DATA field    TYPE REF TO data.

    lo_table ?= handle.

    call(
      EXPORTING
        handle = lo_table->get_table_line_type( )
      CHANGING
        dref   = field ).

    WRITE '@KERNEL dref.assign(new abap.types.Table(field));'.
  ENDMETHOD.

  METHOD elem.
    CASE handle->type_kind.
      WHEN cl_abap_typedescr=>typekind_float.
        CREATE DATA dref TYPE f.
      WHEN cl_abap_typedescr=>typekind_string.
        CREATE DATA dref TYPE string.
      WHEN cl_abap_typedescr=>typekind_xstring.
        CREATE DATA dref TYPE xstring.
      WHEN cl_abap_typedescr=>typekind_int.
        CREATE DATA dref TYPE i.
      WHEN cl_abap_typedescr=>typekind_date.
        CREATE DATA dref TYPE d.
      WHEN cl_abap_typedescr=>typekind_hex.
        CREATE DATA dref TYPE x LENGTH handle->length.
      WHEN cl_abap_typedescr=>typekind_char.
        CREATE DATA dref TYPE c LENGTH handle->length.
      WHEN cl_abap_typedescr=>typekind_time.
        CREATE DATA dref TYPE t.
      WHEN OTHERS.
        WRITE '@KERNEL console.dir(handle);'.
        ASSERT 1 = 'todo'.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.