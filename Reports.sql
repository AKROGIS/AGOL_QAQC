-- All items
SELECT * FROM [AGOL_ITEMS] order by numViews desc

-- Item count by owner/access
select [owner], [access], count(*) as items from [AGOL_ITEMS] group by [owner], [access] order by owner, access

-- Number of items by access level
select access, count(*) as items  from [AGOL_ITEMS] group by access

--disabled users
select isnull(d.region, m.Region) as Region, u.username, u.email from AGOL_USERS as u left join DOMAININFO as d on u.username = d.username left join MISSING_USERS as m on u.username = m.username where disabled = 'True' order by d.region, u.username

--enabled users with no content and no AD record (DELETE?)
select isnull(d.region, m.Region) as Region, u.username, u.email from AGOL_USERS as u left join AGOL_ITEMS as i on u.username = i.owner left join DOMAININFO as d on u.username = d.username left join MISSING_USERS as m on u.username = m.username where i.owner is null and d.domain_cn is null and u.disabled = 'False' order by d.region, u.username

--all users needing an AD assignment - No AD record, and NO explanation
select u.username, u.email from AGOL_USERS as u left join DOMAININFO as d on u.username = d.username left join MISSING_USERS as m on u.username = m.username where d.domain_cn is null and m.Region is null order by u.email

--any users without an AD record
select u.username, u.email from AGOL_USERS as u left join DOMAININFO as d on u.username = d.username where d.domain_cn is null order by u.username

--enabled users with content and no AD record (disable or fix account)
select u.username, u.email, count(*) as items  from AGOL_USERS as u left join AGOL_ITEMS as i on u.username = i.owner left join DOMAININFO as d on u.username = d.username left join MISSING_USERS as m on u.username = m.username where i.owner is not null and d.domain_cn is null and m.Region is null and u.disabled = 'False' group by u.username, u.email order by u.username

-- SHEET 1
-- duplicates
select isnull(d.region, m.Region) as Region, u.username, d.email, i.cnt as items from AGOL_USERS as u left join DOMAININFO as d on u.username = d.username left join (select owner, count(*) as cnt from AGOL_ITEMS group by owner) as i on i.owner = u.username left join MISSING_USERS as m on u.username = m.username  where  d.domain_cn in (select domain_cn from DOMAININFO where domain_cn is not null group by domain_cn having count(*) > 1) order by d.region, d.email, u.username

-- SHEET 2
-- disabled users with no content (DELETE?)
select isnull(d.region, m.Region) as Region, u.username, u.email from AGOL_USERS as u left join AGOL_ITEMS as i on u.username = i.owner left join DOMAININFO as d on u.username = d.username left join MISSING_USERS as m on u.username = m.username where i.owner is null and u.disabled = 'True' order by d.region, u.username

-- SHEET 3
-- disabled users with content (move content; then delete?)
select isnull(d.region, m.Region) as Region, u.username, u.email, count(*) as items from AGOL_USERS as u left join AGOL_ITEMS as i on u.username = i.owner left join DOMAININFO as d on u.username = d.username left join MISSING_USERS as m on u.username = m.username where i.owner is not null and u.disabled = 'True' group by d.region, m.Region, u.username, u.email order by d.region, u.username

-- SHEET 4
-- enabled users with no content (viewer?)
select isnull(d.region, m.Region) as Region, u.username, u.email from AGOL_USERS as u left join AGOL_ITEMS as i on u.username = i.owner left join DOMAININFO as d on u.username = d.username left join MISSING_USERS as m on u.username = m.username where i.owner is null and u.disabled = 'False' order by d.region, u.username

-- SHEET 5
-- enabled users with content (creators)
select isnull(d.region, m.Region) as Region, u.username, u.email, count(*) as items from AGOL_USERS as u left join AGOL_ITEMS as i on u.username = i.owner left join DOMAININFO as d on u.username = d.username left join MISSING_USERS as m on u.username = m.username where i.owner is not null and u.disabled = 'False' group by d.region, m.region, u.username, u.email order by d.region, u.username

-- SHEET 6
-- Number of public items by owner
select isnull(d.region, m.Region) as Region, i.[owner], count(*) as public_items from [AGOL_ITEMS] as i left join DOMAININFO as d on i.[owner] = d.username left join MISSING_USERS as m on i.[owner] = m.username where access = 'public' group by d.region, m.Region, i.[owner] order by public_items desc

-- SHEET 7
-- number of public views by user
select isnull(d.region, m.Region) as Region, i.[owner], sum(numViews) as [views] from [AGOL_ITEMS] as i left join DOMAININFO as d on i.[owner] = d.username left join MISSING_USERS as m on i.[owner] = m.username where access = 'public' group by d.region, m.region, i.[owner] order by [views] desc

-- SHEET 8
-- Number of public items with missing metadata
select isnull(d.region, m.Region) as Region, i.[owner], COALESCE(md.cnt,0) as missing_desc, COALESCE(ms.cnt,0) as missing_snip, COALESCE(mi.cnt,0) as missing_thumb, tm.cnt as items_w_issues, count(*) as total_items from [AGOL_ITEMS] as i
left join DOMAININFO as d on i.[owner] = d.username
left join (select [owner], count(*) as cnt from [AGOL_ITEMS] where access = 'public' and len_desc is null group by [owner]) as md on md.[owner] = i.[owner]
left join (select [owner], count(*) as cnt from [AGOL_ITEMS] where access = 'public' and len_snippet is null group by [owner]) as ms on ms.[owner] = i.[owner]
left join (select [owner], count(*) as cnt from [AGOL_ITEMS] where access = 'public' and thumbnail is null and type not in ('Image', 'PDF') group by [owner]) as mi on mi.[owner] = i.[owner]
left join (select [owner], count(*) as cnt from [AGOL_ITEMS] where access = 'public' and (len_desc is null or len_snippet is null or (thumbnail is null and type not in ('Image', 'PDF'))) group by [owner]) as tm on tm.[owner] = i.[owner]
left join MISSING_USERS as m on i.[owner] = m.username 
where access = 'public' and tm.cnt is not null group by d.region, m.region, i.[owner], md.cnt, ms.cnt, mi.cnt, tm.cnt order by d.region, i.[owner]

--SHEET 9
--all users needing an AD assignment - No AD record, and NO explanation
select u.username, u.email from AGOL_USERS as u left join DOMAININFO as d on u.username = d.username left join MISSING_USERS as m on u.username = m.username where d.domain_cn is null and m.Region is null order by u.email

