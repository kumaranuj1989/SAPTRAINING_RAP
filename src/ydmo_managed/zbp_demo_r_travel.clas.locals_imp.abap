CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS cancel_travel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~cancel_travel RESULT result.

    METHODS issue_message FOR MODIFY
      IMPORTING keys FOR ACTION Travel~issue_message.

    METHODS determineStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Travel~determineStatus.

    METHODS validateBeginDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateBeginDate.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDateSequence FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDateSequence.

    METHODS validateDescription FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDescription.

    METHODS validateEndDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateEndDate.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE Travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
    result = CORRESPONDING #( keys ).
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Below code can be used to authorize for accessing Cancel Travel button
*    LOOP AT result ASSIGNING FIELD-SYMBOL(<result>).
*
*      DATA(rc) =  ycl_demo_model=>authority_check(
*                              i_agencyid  = <result>-agencyid
*                              i_actvt     = '02' ).
*
*      IF rc <> 0.
*        <result>-%action-cancel_travel = if_abap_behv=>auth-unauthorized.
*      ELSE.
*        <result>-%action-cancel_travel = if_abap_behv=>auth-allowed.
*      ENDIF.
*
*    ENDLOOP.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancel_travel.
    "   Read the selected entity based on the keys
    READ ENTITIES OF ydemo_R_TRAVEL IN LOCAL MODE
    ENTITY Travel
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

    IF lt_result IS NOT INITIAL.
      LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).

        IF <lfs_result>-Status <> 'C'.
          " Modify the entity with Status C where by passing the key
          MODIFY ENTITIES OF ydemo_R_TRAVEL IN LOCAL MODE
          ENTITY Travel
          UPDATE FIELDS ( Status ) WITH VALUE #( (  %tky = <lfs_result>-%tky
                                                   Status = 'C' ) ).

          INSERT VALUE #( %msg     = NEW ycl_demo_msg( textid = ycl_demo_msg=>cancel_success
                          severity = if_abap_behv_message=>severity-success  ) )
                 INTO TABLE reported-travel.

          "Insert key field and the whole structure of that particular records
          INSERT VALUE #( %tky = <lfs_result>-%tky %param = <lfs_result> ) INTO TABLE result.

        ELSE.
          APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-travel.
          APPEND VALUE #( %tky = <lfs_result>-%tky
                          %element-TravelId = if_abap_behv=>mk-on
                          %msg = NEW ycl_demo_msg( textid = ycl_demo_msg=>already_canceled ) ) TO reported-travel.

        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD issue_message.
    INSERT VALUE #( %msg     = NEW ycl_demo_msg( textid = ycl_demo_msg=>issue_message
                           severity = if_abap_behv_message=>severity-success  ) )
                  INTO TABLE reported-travel.
  ENDMETHOD.

  METHOD determineStatus.
    READ ENTITIES OF ydemo_R_TRAVEL IN LOCAL MODE
      ENTITY Travel
      FIELDS ( Status )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    DELETE lt_result WHERE Status IS NOT INITIAL.
    CHECK lt_result IS NOT INITIAL.

    MODIFY ENTITIES OF ydemo_R_TRAVEL IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS ( Status )
    WITH VALUE #( FOR ls_Result IN lt_Result ( %tky = ls_Result-%tky
                                               Status = 'N' ) )
    REPORTED DATA(lt_reported)
    MAPPED   DATA(lt_mapped).

    reported = CORRESPONDING #( DEEP lt_reported ).
  ENDMETHOD.

  METHOD validateCustomer.
    READ ENTITIES OF ydemo_R_TRAVEL IN LOCAL MODE
    ENTITY Travel
    FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      IF <lfs_result>-CustomerId IS INITIAL.
        APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-travel.

        APPEND VALUE #(  %tky = <lfs_result>-%tky
                         %msg = NEW ycl_demo_msg( ycl_demo_msg=>field_empty )
                         %element-CustomerId = if_abap_behv=>mk-on ) TO reported-travel.
      ELSE.
        SELECT SINGLE FROM /dmo/i_customer FIELDS CustomerID WHERE CustomerID = @<lfs_result>-CustomerId INTO @DATA(dummy).
        IF sy-subrc IS NOT INITIAL.
          APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-travel.

          APPEND VALUE #(  %tky = <lfs_result>-%tky
                         %msg = NEW ycl_demo_msg( ycl_demo_msg=>customer_not_exist )
                         %element-CustomerId = if_abap_behv=>mk-on ) TO reported-travel.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDescription.
    READ ENTITIES OF ydemo_R_TRAVEL IN LOCAL MODE
    ENTITY Travel
    FIELDS ( Description )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      IF <lfs_result>-Description IS INITIAL.
        APPEND VALUE #( %tky = <lfs_result>-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = <lfs_result>-%tky
                        %msg = NEW ycl_demo_msg( ycl_demo_msg=>field_empty )
                        %element-Description = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD validateBeginDate.
    READ ENTITIES OF ydemo_R_TRAVEL IN LOCAL MODE
    ENTITY Travel
    FIELDS ( BeginDate )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    LOOP AT lt_Result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      IF <lfs_result>-BeginDate IS INITIAL.
        APPEND VALUE #(  %tky = <lfs_result>-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = <lfs_result>-%tky
                        %msg = NEW ycl_demo_msg( ycl_demo_msg=>field_empty )
                        %element-BeginDate = if_abap_behv=>mk-on ) TO reported-travel.
      ELSEIF <lfs_result>-BeginDate LT cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #(  %tky = <lfs_result>-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = <lfs_result>-%tky
                          %msg = NEW ycl_demo_msg( ycl_demo_msg=>begin_date_past )
                          %element-BeginDate = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateEndDate.
    READ ENTITIES OF ydemo_R_TRAVEL IN LOCAL MODE
      ENTITY Travel
      FIELDS ( EndDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result).

    LOOP AT lt_Result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      IF <lfs_result>-EndDate IS INITIAL.
        APPEND VALUE #(  %tky = <lfs_result>-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = <lfs_result>-%tky
                        %msg = NEW ycl_demo_msg( ycl_demo_msg=>field_empty )
                        %element-EndDate = if_abap_behv=>mk-on ) TO reported-travel.
      ELSEIF <lfs_result>-EndDate LT cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #(  %tky = <lfs_result>-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = <lfs_result>-%tky
                          %msg = NEW ycl_demo_msg( ycl_demo_msg=>end_date_past )
                          %element-EndDate = if_abap_behv=>mk-on ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDateSequence.
    READ ENTITIES OF ydemo_R_TRAVEL IN LOCAL MODE
       ENTITY Travel
       FIELDS ( BeginDate EndDate )
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_result).

    LOOP AT lt_Result ASSIGNING FIELD-SYMBOL(<lfs_result>).
      IF <lfs_result>-EndDate LT <lfs_result>-BeginDate.
        APPEND VALUE #(  %tky = <lfs_result>-%tky ) TO failed-travel.

        APPEND VALUE #( %tky = <lfs_result>-%tky
                          %msg = NEW ycl_demo_msg( ycl_demo_msg=>dates_wrong_sequence )
                          %element = VALUE #( BeginDate = if_abap_behv=>mk-on
                                              EndDate   = if_abap_behv=>mk-on ) ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA(agencyid) = ycl_demo_model=>get_agency_by_user(  ).

    mapped-travel = CORRESPONDING #( entities ).

    LOOP AT mapped-travel ASSIGNING FIELD-SYMBOL(<mapping>).
      <mapping>-agencyid = agencyid.
      <mapping>-travelid = ycl_demo_model=>get_next_travelid( ).
    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF ydemo_R_TRAVEL IN LOCAL MODE
       ENTITY Travel
       FIELDS ( Status BeginDate EndDate )
       WITH CORRESPONDING #( keys )
       RESULT DATA(lt_travel).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<lfs_travel>).
    "In instance-based feature control, it is important that you add a row to result for each row of keys. If you fail to do so, it leads to a runtime error.
      APPEND CORRESPONDING #( <lfs_travel> ) TO result ASSIGNING FIELD-SYMBOL(<lfs_result>).

      IF <lfs_travel>-Status = 'C' OR
         ( <lfs_travel>-EndDate IS NOT INITIAL AND <lfs_travel>-EndDate <  cl_abap_context_info=>get_system_date( ) ).

        <lfs_result>-%update = if_abap_behv=>fc-o-disabled.
        <lfs_result>-%action-cancel_travel = if_abap_behv=>fc-o-disabled.

      ELSE.
        <lfs_result>-%update = if_abap_behv=>fc-o-enabled.
        <lfs_result>-%action-cancel_travel = if_abap_behv=>fc-o-enabled.
      ENDIF.

      IF <lfs_travel>-begindate IS NOT INITIAL AND
         <lfs_travel>-begindate < cl_abap_context_info=>get_system_date( ).

        <lfs_result>-%field-customerid = if_abap_behv=>fc-f-read_only.
        <lfs_result>-%field-begindate  = if_abap_behv=>fc-f-read_only.

      ELSE.

        <lfs_result>-%field-customerid = if_abap_behv=>fc-f-mandatory.
        <lfs_result>-%field-begindate  = if_abap_behv=>fc-f-mandatory.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
