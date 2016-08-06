-- All items
SELECT * FROM [AGOL_ITEMS] order by numViews desc

-- Item count by owner/access
select [owner], [access], count(*) as items from [AGOL_ITEMS] group by [owner], [access] order by owner, access

-- Number of public items by owner
select d.region, i.[owner], count(*) as public_items from [AGOL_ITEMS] as i left join DOMAININFO as d on i.[owner] = d.username where access = 'public' group by d.region, i.[owner] order by public_items desc

-- Number of items by access level
select access, count(*) as items  from [AGOL_ITEMS] group by access

-- Number of public items with missing metadata
select d.region, i.[owner], COALESCE(md.cnt,0) as missing_desc, COALESCE(ms.cnt,0) as missing_snip, COALESCE(mi.cnt,0) as missing_thumb, tm.cnt as items_w_issues, count(*) as total_items from [AGOL_ITEMS] as i
left join DOMAININFO as d on i.[owner] = d.username
left join (select [owner], count(*) as cnt from [AGOL_ITEMS] where access = 'public' and len_desc is null group by [owner]) as md on md.[owner] = i.[owner]
left join (select [owner], count(*) as cnt from [AGOL_ITEMS] where access = 'public' and len_snippet is null group by [owner]) as ms on ms.[owner] = i.[owner]
left join (select [owner], count(*) as cnt from [AGOL_ITEMS] where access = 'public' and thumbnail is null and type not in ('Image', 'PDF') group by [owner]) as mi on mi.[owner] = i.[owner]
left join (select [owner], count(*) as cnt from [AGOL_ITEMS] where access = 'public' and (len_desc is null or len_snippet is null or (thumbnail is null and type not in ('Image', 'PDF'))) group by [owner]) as tm on tm.[owner] = i.[owner]
where access = 'public' and tm.cnt is not null group by d.region, i.[owner], md.cnt, ms.cnt, mi.cnt, tm.cnt order by d.region, i.[owner]

--number of public views by user
select d.region, i.[owner], sum(numViews) as [views] from [AGOL_ITEMS] as i left join DOMAININFO as d on i.[owner] = d.username where access = 'public' group by d.region, i.[owner] order by [views] desc

--disabled users
select d.region, u.username, u.email from AGOL_USERS as u left join DOMAININFO as d on u.username = d.username where disabled = 'True' order by d.region, u.username

--disabled users with no content (DELETE?)
select d.region, u.username, u.email from AGOL_USERS as u left join AGOL_ITEMS as i on u.username = i.owner left join DOMAININFO as d on u.username = d.username where i.owner is null and u.disabled = 'True' order by d.region, u.username

--disabled users with content (move content; then delete?)
select d.region, u.username, u.email, count(*) as items from AGOL_USERS as u left join AGOL_ITEMS as i on u.username = i.owner left join DOMAININFO as d on u.username = d.username where i.owner is not null and u.disabled = 'True' group by d.region, u.username, u.email order by d.region, u.username

--enabled users with no content (viewer?)
select d.region, u.username, u.email from AGOL_USERS as u left join AGOL_ITEMS as i on u.username = i.owner left join DOMAININFO as d on u.username = d.username where i.owner is null and u.disabled = 'False' order by d.region, u.username

--enabled users with content (creators)
select d.region, u.username, u.email, count(*) as items from AGOL_USERS as u left join AGOL_ITEMS as i on u.username = i.owner left join DOMAININFO as d on u.username = d.username where i.owner is not null and u.disabled = 'False' group by d.region, u.username, u.email order by d.region, u.username

--enabled users with no content and no AD record (DELETE?)
select d.region, u.username, u.email from AGOL_USERS as u left join AGOL_ITEMS as i on u.username = i.owner left join DOMAININFO as d on u.username = d.username where i.owner is null and d.domain_cn is null and u.disabled = 'False' order by d.region, u.username

--enabled users with content and no AD record (disable or fix account)
select d.region, u.username, u.email, count(*) as items  from AGOL_USERS as u left join AGOL_ITEMS as i on u.username = i.owner left join DOMAININFO as d on u.username = d.username where i.owner is not null and d.domain_cn is null  and u.disabled = 'False' group by d.region, u.username, u.email order by d.region, u.username

--duplicates
select d.region, u.username, d.email, i.cnt as items from AGOL_USERS as u left join DOMAININFO as d on u.username = d.username left join (select owner, count(*) as cnt from AGOL_ITEMS group by owner) as i on i.owner = u.username where  d.domain_cn in (select domain_cn from DOMAININFO where domain_cn is not null group by domain_cn having count(*) > 1) order by d.region, d.email, u.username
