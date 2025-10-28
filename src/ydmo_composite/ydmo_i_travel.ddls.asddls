@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface view for Travel'
@Metadata.ignorePropagatedAnnotations: true
define view entity YDMO_I_TRAVEL
  as select from ydmo_travel
{
  key agency_id      as AgencyId,
  key travel_id      as TravelId,
      description    as Description,
      customer_id    as CustomerId,
      begin_date     as BeginDate,
      end_date       as EndDate,
      status         as Status,
      changed_at     as ChangedAt,
      changed_by     as ChangedBy,
      loc_changed_at as LocChangedAt
}
