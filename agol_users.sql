--Update Region setting in AGOL users table
update AGOL_USERS set region = NULL
update u set region = ad.region from AGOL_USERS as u join NPS_EMAILS as ad on u.email = ad.email where u.region is null and ad.region is not null and ad.region <> 'Move'
update u set region = ad.region from AGOL_USERS as u join NPS_EMAILS as ad on u.email = ad.[login] where u.region is null and ad.region is not null and ad.region <> 'Move'
update u set region = m.region from AGOL_USERS as u join MISSING_USERS as m on u.username = m.username where u.region is null and m.region is not null

-- Tab 1) All AGOL Users (with Region assignment)
SELECT [username],[email],[region],[disabled],[firstName],[lastName],[userType],[created],[lastLogin],[access],[role],[description] FROM [Scratch].[dbo].[AGOL_USERS]

-- Tab 2) Region count
select region, count(*) from AGOL_USERS group by region

--Tab 3) all users needing an AD assignment - No AD record, and NO explanation
select u.username, u.email, u.disabled,
case when u.email like '%nps.gov' then 'Y' else 'N' end as nps,
coalesce(i.num, 0) as item_count
from AGOL_USERS as u left join (select owner, count(*) as num from AGOL_ITEMS group by owner) as i on i.owner = u.username
where region is null
order by u.disabled, case when i.num is null then 1 else 0 end,
nps desc, username

-- Tab 4) AGOL Accounts with an NPS email not in AD
select u.username, u.email, u.region, m.comment from AGOL_USERS as u left join NPS_Emails as e on u.email = e.email left join MISSING_USERS as m on m.username = u.username where e.email IS NULL and u.email like '%nps.gov'




-- non NPS emails
select username, email from AGOL_USERS where email not like '%nps.gov'

--AGOL users without a Region
select * from AGOL_USERS where region is null

--AGOL users with NPS email without a Region
select username from AGOL_USERS where email like '%nps.gov' and region is null order by username

-- Un-needed records in missing 
select u.region, u.username from MISSING_USERS as u left join AGOL_USERS as a on u.username = a.username left join NPS_EMAILS as m1 on a.email = m1.email or a.email = m1.login where a.username is null or m1.email is not null  and m1.region <> 'Move' order by u.region, u.username

-- Accounts without a region code
select u.username, u.email, u.disabled,
case when u.email like '%nps.gov' then 'Y' else 'N' end as nps,
coalesce(i.num, 0) as item_count
from AGOL_USERS as u left join (select owner, count(*) as num from AGOL_ITEMS group by owner) as i on i.owner = u.username
where region is null
order by u.disabled, case when i.num is null then 1 else 0 end,
nps desc, username



-- SHEET 1
-- duplicates
select u.region, u.username, email, i.cnt as items from AGOL_USERS as u left join (select owner, count(*) as cnt from AGOL_ITEMS group by owner) as i on i.owner = u.username where  email in (select email from AGOL_USERS where email is not null group by email having count(*) > 1) order by u.region, email, u.username


-- SHEET 2
-- disabled users with no content (DELETE?)
select u.Region, u.username, u.email from AGOL_USERS as u left join AGOL_ITEMS as i on u.username = i.owner where i.owner is null and u.disabled = 'True' order by u.Region, u.username

-- SHEET 3
-- disabled users with content (move content; then delete?)
select u.Region, u.username, u.email, count(*) as items from AGOL_USERS as u left join AGOL_ITEMS as i on u.username = i.owner where i.owner is not null and u.disabled = 'True' group by u.Region, u.username, u.email order by u.Region, u.username

-- SHEET 4
-- enabled users with no content (viewer?)
select u.Region, u.username, u.email from AGOL_USERS as u left join AGOL_ITEMS as i on u.username = i.owner where i.owner is null and u.disabled = 'False' order by u.Region, u.username

-- SHEET 5
-- enabled users with content (creators)
select u.Region, u.username, u.email, count(*) as items from AGOL_USERS as u left join AGOL_ITEMS as i on u.username = i.owner where i.owner is not null and u.disabled = 'False' group by u.region, u.username, u.email order by u.Region, u.username

-- SHEET 6
-- Number of public items by owner
select u.Region, i.[owner], count(*) as public_items from [AGOL_ITEMS] as i left join AGOL_USERS as u on i.[owner] = u.username where i.access = 'public' group by u.Region, i.[owner] order by public_items desc

-- SHEET 7
-- number of public views by user
select u.Region, i.[owner], sum(numViews) as [views] from [AGOL_ITEMS] as i left join AGOL_USERS as u on i.[owner] = u.username where i.access = 'public' group by u.region, i.[owner] order by [views] desc

-- SHEET 8
-- Number of public items with missing metadata
select u.Region, i.[owner], COALESCE(md.cnt,0) as missing_desc, COALESCE(ms.cnt,0) as missing_snip, COALESCE(mi.cnt,0) as missing_thumb, tm.cnt as items_w_issues, count(*) as total_items from [AGOL_ITEMS] as i
left join AGOL_USERS as u on i.[owner] = u.username
left join (select [owner], count(*) as cnt from [AGOL_ITEMS] where access = 'public' and len_desc is null group by [owner]) as md on md.[owner] = i.[owner]
left join (select [owner], count(*) as cnt from [AGOL_ITEMS] where access = 'public' and len_snippet is null group by [owner]) as ms on ms.[owner] = i.[owner]
left join (select [owner], count(*) as cnt from [AGOL_ITEMS] where access = 'public' and thumbnail is null and type not in ('Image', 'PDF') group by [owner]) as mi on mi.[owner] = i.[owner]
left join (select [owner], count(*) as cnt from [AGOL_ITEMS] where access = 'public' and (len_desc is null or len_snippet is null or (thumbnail is null and type not in ('Image', 'PDF'))) group by [owner]) as tm on tm.[owner] = i.[owner]
where i.access = 'public' and tm.cnt is not null group by u.region, i.[owner], md.cnt, ms.cnt, mi.cnt, tm.cnt order by u.Region, i.[owner]

--SHEET 9
--all users needing an AD assignment - No AD record, and NO explanation
select u.username, u.email, u.disabled,
case when u.email like '%nps.gov' then 'Y' else 'N' end as nps,
coalesce(i.num, 0) as item_count
from AGOL_USERS as u left join (select owner, count(*) as num from AGOL_ITEMS group by owner) as i on i.owner = u.username
where region is null
order by u.disabled, case when i.num is null then 1 else 0 end,
nps desc, username


