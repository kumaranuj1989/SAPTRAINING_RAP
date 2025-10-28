@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Composite view for Travel'
@Metadata.ignorePropagatedAnnotations: true
define root view entity YDMO_R_TRAVEL
  as select from YDMO_I_TRAVEL
  composition [0..*] of YDMO_R_TRAVELITEM as _TravelItem
{
  key AgencyId,
  key TravelId,
      Description,
      CustomerId,
      BeginDate,
      EndDate,
      @EndUserText.label: 'Duration (days)'
      dats_days_between( BeginDate, EndDate ) as Duration,
      Status,
      @Semantics.systemDateTime.lastChangedAt: true
      ChangedAt,
      @Semantics.user.lastChangedBy: true
      ChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocChangedAt,
      _TravelItem // Make association public
}
