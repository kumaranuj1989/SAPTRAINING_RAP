@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection view for Travel'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity YDMO_C_TRAVEL
  provider contract transactional_query
  as projection on YDMO_R_TRAVEL
{
  key AgencyId,
  key TravelId,
      Description,
      CustomerId,
      BeginDate,
      EndDate,
      Duration,
      Status,
      ChangedAt,
      ChangedBy,
      LocChangedAt,
      /* Associations */
      _TravelItem : redirected to composition child YDMO_C_TRAVELITEM
}
