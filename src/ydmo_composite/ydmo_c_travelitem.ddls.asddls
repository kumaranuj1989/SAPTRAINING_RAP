@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Travel Item'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity YDMO_C_TRAVELITEM
  as projection on YDMO_R_TRAVELITEM
{
  key ItemUuid,
      AgencyId,
      TravelId,
      CarrierId,
      ConnectionId,
      FlightDate,
      BookingId,
      PassengerFirstName,
      PassengerLastName,
      ChangedAt,
      ChangedBy,
      LocChangedAt,
      /* Associations */
      _Travel : redirected to parent YDMO_C_TRAVEL
}
