using System;
using System.CodeDom;
using System.Collections.Generic;
using System.Diagnostics;
using System.DirectoryServices;
using System.DirectoryServices.AccountManagement;
using System.IO;
using System.Linq;
using System.Threading;
using MyExtensions;

namespace MyExtensions
{
    public static class AccountManagementExtensions
    {

        public static string GetProperty(this Principal principal, string property)
        {
            DirectoryEntry directoryEntry = principal.GetUnderlyingObject() as DirectoryEntry;
            if (directoryEntry != null && directoryEntry.Properties.Contains(property))
                return directoryEntry.Properties[property].Value.ToString();
            return string.Empty;
        }

        public static string GetEmail(this Principal principal)
        {
            return principal.GetProperty("mail");
        }

        public static string GetGivenName(this Principal principal)
        {
            return principal.GetProperty("givenName");
        }

        public static string GetSurName(this Principal principal)
        {
            return principal.GetProperty("sn");
        }

        public static string GetPhone(this Principal principal)
        {
            return principal.GetProperty("telephoneNumber");
        }

    }
}

namespace query_ldap
{
    class Program
    {
        static void Main(string[] args)
        {
            //SearchSurname("Hamilton*"); return;
            if (args.Length != 2)
            {
                Console.WriteLine("USAGE query_ldap infile outfile");
                return;
            }
            var context = new PrincipalContext(ContextType.Domain, "nps", "DC=nps,DC=doi,DC=net");
            Console.WriteLine(context.ConnectedServer);
            var file = new List<string>();
            file.Add("username,email,region,login,domain_cn");
            var c = 0;
            foreach (string line in File.ReadLines(args[0]).Skip(1))
            {
                c += 1; if (c % 10 == 0) Console.Write(".");  // Show progress

                var columns = line.Split(',');
                if (columns.Length < 6)
                {
                    Console.WriteLine("BAD LINE: " + line);
                    continue;
                }
                var username = columns[0];
                var email = columns[1];
                var firstname = columns[4];
                var lastname = columns[5];
                Principal p = MatchEmail(context, email);
                if (p != null)
                {
                    //Debug.WriteLine("email match: "+ username + " on " + email);
                    file.Add(username + "," + email + "," + Region(p.DistinguishedName) + ",NPS\\" + p.SamAccountName + ",\"" + p.DistinguishedName+ "\"");
                }
                else
                {
                    p = MatchNames(context, lastname, firstname);
                    if (p != null)
                    {
                        //Debug.WriteLine("name match: " + username + " on " + lastname + "|" + firstname);
                        file.Add(username + "," + email + "|" + p.GetEmail() + "," + Region(p.DistinguishedName) + ",NPS\\" + p.SamAccountName + ",\"" + p.DistinguishedName + "\"");
                    }
                    else
                    {
                        file.Add(username + ",,,,");
                    }
                }
            }
            File.WriteAllLines(args[1],file);
        }
        static void SearchSurname(string search)
        {
            var context = new PrincipalContext(ContextType.Domain, "nps", "DC=nps,DC=doi,DC=net");
            var query = new UserPrincipal(context) { Surname = search, Enabled = true };
            var searcher = new PrincipalSearcher { QueryFilter = query };
            foreach (Principal p in searcher.FindAll())
            {
                Debug.WriteLine(search + "," + p.GetGivenName() + "," + p.GetSurName() + "," + p.DisplayName + "," + p.Description + "," + p.UserPrincipalName + "," + Region(p.DistinguishedName) + ",NPS\\" + p.SamAccountName + ",\"" + p.DistinguishedName + "\"");
            }
        }
        static Principal MatchEmail(PrincipalContext context, string email)
        {
            var query = new UserPrincipal(context) { EmailAddress = email, Enabled = true};
            var searcher = new PrincipalSearcher { QueryFilter = query };
            return searcher.FindOne();
        }
        static Principal MatchNames(PrincipalContext context, string lastname, string firstname)
        {
            if (string.IsNullOrEmpty(lastname)) return null;
            if (string.IsNullOrEmpty(firstname)) return null;

            var query = new UserPrincipal(context) { Surname = lastname, GivenName = firstname, Enabled = true };
            var searcher = new PrincipalSearcher { QueryFilter = query };
            return searcher.FindOne();
        }
        static string Region(string distinguishedName)
        {
            string[] regions = {"AKR", "IMR", "MWR", "PWR", "NCR", "SER", "NER", "NIFC", "NRPC", "USPP", "DSC", "WAS", "DEN"};
            foreach (var region in regions)
            {
                if (distinguishedName.Contains("OU=" + region))
                {
                    return region;
                }
            }
            return string.Empty;
        }
    }
}
