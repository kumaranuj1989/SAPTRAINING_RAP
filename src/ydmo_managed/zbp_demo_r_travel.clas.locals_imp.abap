CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS cancel_travel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~cancel_travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
    result = CORRESPONDING #( keys ).

    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>).

      DATA(rc) =  ycl_demo_model=>authority_check(
                              i_agencyid  = <result>-agencyid
                              i_actvt     = '03' ).

      IF rc <> 0.
        <result>-%action-cancel_travel = if_abap_behv=>auth-unauthorized.
        <result>-%update               = if_abap_behv=>auth-unauthorized.
      ELSE.
        <result>-%action-cancel_travel = if_abap_behv=>auth-allowed.
        <result>-%update               = if_abap_behv=>auth-allowed.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancel_travel.

    READ ENTITIES OF ydemo_R_TRAVEL IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

    IF lt_result IS NOT INITIAL.
      LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).

        IF <lfs_result>-Status <> 'C'.
          MODIFY ENTITIES OF ydemo_R_TRAVEL IN LOCAL MODE
          ENTITY Travel
          UPDATE FIELDS ( Status ) WITH VALUE #( (  %tky = <lfs_result>-%tky
                                                   Status = 'C' ) ).

        ELSE.
          APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-travel.
          APPEND VALUE #( %tky = <lfs_result>-%tky
                          %element-TravelId = if_abap_behv=>mk-on
                          %msg = new_message_with_text( text = 'Already Cancelled' ) ) TO reported-travel.

        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
