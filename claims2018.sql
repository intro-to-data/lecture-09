with EnrolledMembersCTE as
(
    select
         MemberID
        ,PayerCD
        ,OrganizationCD
        ,count(MonthNBR) MbrMonths
    from SharedCDPHP.Claim.MemberEnrollment
    where YearNBR = 2018
    group by
         MemberID
        ,PayerCD
        ,OrganizationCD
    having count(MonthNBR) >= 9
)

, ClaimsCTE as 
(
    select 
        ch.MemberID 
       ,ch.PayerCD 
       ,ch.OrganizationCD
       ,year(ch.ClaimEndDTS) ClaimYearNBR
       ,ch.EDFLG 
       ,ch.InpatientAdmitFLG
       ,row_number() over(partition by ch.MemberID, ch.ClaimStartDTS ,ch.ClaimEndDTS order by ch.ClaimStartDTS , ch.ClaimEndDTS) as rn
    from SharedCDPHP.Claim.ClaimHeader ch
    where year(ch.ClaimEndDTS) = 2018
)

, EventsCTE as
(
    select
        clm.MemberID
       ,clm.PayerCD
       ,clm.OrganizationCD
       ,clm.ClaimYearNBR
       ,sum(clm.EDFLG) as EmergencyDeptNBR
       ,sum(clm.InpatientAdmitFLG) as InpatientNBR
    from ClaimsCTE clm
    where clm.rn = 1
    group by 
         clm.MemberID
        ,clm.PayerCD
        ,clm.OrganizationCD
        ,clm.ClaimYearNBR
)

, ChargesCTE as
(
    select MemberID, PayerCD, OrganizationCD, sum(TotalPaidAMT) TotalPaidAMT, sum(MemberResponsibilityAMT) MemberResponsibilityAMT 
    from SharedCDPHP.Claim.ClaimHeader ch
    where year(ClaimEndDTS) = 2018
    group by MemberID, PayerCD, OrganizationCD
)

select 
     mem.MemberID
    ,mem.PayerCD
    ,mem.OrganizationCD
    ,mem.MbrMonths
    ,chr.TotalPaidAMT
    ,chr.MemberResponsibilityAMT
    ,eve.EmergencyDeptNBR
    ,eve.InpatientNBR
from EnrolledMembersCTE mem
left join EventsCTE eve
on 
    mem.PayerCD = eve.PayerCD 
    and mem.OrganizationCD = eve.OrganizationCD 
    and mem.MemberID = eve.MemberID
left join ChargesCTE chr
on 
    mem.MemberID = chr.MemberID
    and mem.PayerCD = chr.PayerCD
    and mem.OrganizationCD = chr.OrganizationCD
order by eve.EmergencyDeptNBR desc
;