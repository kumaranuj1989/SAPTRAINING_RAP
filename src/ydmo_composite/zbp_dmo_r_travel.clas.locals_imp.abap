CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_travelitem DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateFlightDate FOR VALIDATE ON SAVE
      IMPORTING keys FOR TravelItem~validateFlightDate.
    METHODS determineTravelDates FOR DETERMINE ON SAVE
      IMPORTING keys FOR TravelItem~determineTravelDates.

ENDCLASS.

CLASS lhc_travelitem IMPLEMENTATION.

  METHOD validateFlightDate.
    CONSTANTS c_area TYPE string VALUE `FLIGHTDATE`.

    READ ENTITIES OF ydmo_r_travel IN LOCAL MODE
         ENTITY TravelItem
         FIELDS ( agencyid travelid flightdate )
         WITH CORRESPONDING #(  keys )
         RESULT DATA(items).


    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).
      APPEND VALUE #( %tky = <item>-%tky
                      %state_area = c_area
                      %path = CORRESPONDING #(  <item> ) )
            TO reported-travelitem.

      IF <item>-FlightDate IS INITIAL.
        APPEND VALUE #( %tky = <item>-%tky ) TO failed-travelitem.
        APPEND VALUE #( %tky = <item>-%tky
                       %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>field_empty )
                       %element-FlightDate = if_abap_behv=>mk-on
                       %state_area = c_area
                       %path-travel = CORRESPONDING #( <item> ) ) TO reported-travelitem.

      ELSEIF <item>-FlightDate < cl_abap_context_info=>get_system_date( ).
        APPEND VALUE #( %tky = <item>-%tky
                       %msg = NEW /lrn/cm_s4d437( /lrn/cm_s4d437=>flight_date_past )
                       %element-FlightDate = if_abap_behv=>mk-on
                       %state_area = c_area
                       %path-travel = CORRESPONDING #( <item> ) ) TO reported-travelitem.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD determineTravelDates.

    READ ENTITIES OF ydmo_r_travel IN LOCAL MODE
           ENTITY TravelItem
           FIELDS ( FlightDate )
            WITH CORRESPONDING #(  keys )
           RESULT DATA(items)

           BY \_Travel
           FIELDS ( BeginDate EndDate )
           WITH CORRESPONDING #( keys )
           RESULT DATA(travels) LINK DATA(link).

    LOOP AT items ASSIGNING FIELD-SYMBOL(<item>).
*      ASSIGN travels[ %tky = link[ source-%tky = <item>-%tky ]-target-%tky ]
*          TO FIELD-SYMBOL(<travel>).

*      READ TABLE travels ASSIGNING FIELD-SYMBOL(<travel>)
*            WITH KEY %tky = link[ source-%tky = <item>-%tky ]-target-%tky.
*
      ASSIGN travels[ KEY id %tky = link[ KEY id source-%tky = <item>-%tky ]-target-%tky ]
          TO FIELD-SYMBOL(<travel>).

      IF <travel>-enddate < <item>-flightdate.
        <travel>-enddate = <item>-flightdate.
      ENDIF.

      IF <item>-flightdate >= cl_abap_context_info=>get_system_date( )
         AND <item>-flightdate  < <travel>-begindate.
        <travel>-begindate = <item>-flightdate.
      ENDIF.
    ENDLOOP.

    MODIFY ENTITIES OF ydmo_r_travel IN LOCAL MODE
   ENTITY travel
     UPDATE
     FIELDS ( begindate enddate )
        WITH CORRESPONDING #(  travels ).
  ENDMETHOD.

ENDCLASS.
