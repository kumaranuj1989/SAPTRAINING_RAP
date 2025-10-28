@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for Travel Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity YDMO_I_TRAVELITEM
  as select from ydmo_travelitem
{
  key item_uuid            as ItemUuid,
      agency_id            as AgencyId,
      travel_id            as TravelId,
      carrier_id           as CarrierId,
      connection_id        as ConnectionId,
      flight_date          as FlightDate,
      booking_id           as BookingId,
      passenger_first_name as PassengerFirstName,
      passenger_last_name  as PassengerLastName,
      changed_at           as ChangedAt,
      changed_by           as ChangedBy,
      loc_changed_at       as LocChangedAt
}
