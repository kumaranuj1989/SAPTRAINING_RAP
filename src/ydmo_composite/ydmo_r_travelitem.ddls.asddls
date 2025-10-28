@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Composite view for Travel Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity YDMO_R_TRAVELITEM
  as select from YDMO_I_TRAVELITEM
  association to parent YDMO_R_TRAVEL as _Travel on  $projection.AgencyId = _Travel.AgencyId
                                                 and $projection.TravelId = _Travel.TravelId
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
      @Semantics.systemDateTime.lastChangedAt: true
      ChangedAt,
      @Semantics.user.lastChangedBy: true
      ChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocChangedAt,
      _Travel // Make association public
}
