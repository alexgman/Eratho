using System;
using System.Collections.Generic;
using System.ServiceModel.Description;
using System.Configuration;

// These namespaces are found in the Microsoft.Xrm.Sdk.dll assembly
// located in the SDK\bin folder of the SDK download.
using Microsoft.Xrm.Sdk.Client;
using Microsoft.Xrm.Sdk.Discovery;
using System.Text;
using System.Net;

namespace CRM2011Helpers
{

    /// <summary>
    /// Creates a connection to the CRM server
    /// </summary>
    public class ServerConnection
    {
        #region Inner classes
        /// <summary>
        /// Stores CRM server configuration information.
        /// </summary>
        public class Configuration
        {
            /// <summary>
            /// The address of the CRM server root URL
            /// For online this will look like [your org url prefix].crm.dynamics.com
            /// For on-premise, this will be [servername]/[orgname]
            /// DO NOT enter http:// or https://
            /// </summary>
            public String ServerAddress;

            /// <summary>
            /// The Organization service URI
            /// </summary>
            public Uri OrganizationUri;

            /// <summary>
            /// Not sure what this is for, currently always null
            /// </summary>
            public Uri HomeRealmUri = null;

            /// <summary>
            /// Device credentials - used when authenticating to CRM Online
            /// </summary>
            public ClientCredentials DeviceCredentials = null;

            /// <summary>
            /// User Credentials - for authenticating both online and onpremise/AD
            /// </summary>
            public ClientCredentials Credentials = null;

            /// <summary>
            /// Defines the authentication type of the current crm server
            /// </summary>
            public AuthenticationProviderType EndpointType;

            /// <summary>
            /// flag indicating whether the crm connection should be SSL
            /// </summary>
            public bool ssl = false;

            /// <summary>
            /// username for authentication - only used if NOT using windows/default credentials
            /// </summary>
            public string user = "";

            /// <summary>
            /// password for authentication - only used if NOT using windows/default credentials
            /// </summary>
            public string password = "";
        }
        #endregion Inner classes

        #region Public properties

        /// <summary>
        /// Org Service Proxy is the primary goal of this class.
        /// This is what we reference in our code to invoke calls against the CRM server.
        /// </summary>
        public OrganizationServiceProxy OrgServiceProxy;

        #endregion Public properties

        #region Private properties

        private Configuration config = new Configuration();

        #endregion Private properties

        #region Public methods

        /// <summary>
        /// Default constructor - simplest, but assumes windows auth, and that you have 
        /// configured crm site (with /orgname) in the .config file. 
        /// Also will not work with https:// - use the advanced constructor in these cases
        /// </summary>
        public ServerConnection()
        {
            //read the information from config file for CRM ROOT URL 
            config.ServerAddress = ConfigurationManager.AppSettings.Get("CRMSite");

            //set the credentials 
            ClientCredentials defaultCreds = new ClientCredentials();
            defaultCreds.Windows.ClientCredential = CredentialCache.DefaultNetworkCredentials;

            config.EndpointType = AuthenticationProviderType.ActiveDirectory;

            //call getserverconfig, etc to set up the configuration 
            GetServerConfiguration();

            //create the OrgServiceProxy
            OrgServiceProxy = GetOrgServiceProxy();

        }

        /// <summary>
        /// Secondary constructor - assumes windows auth, takes the server and ssl flag as input 
        /// </summary>
        public ServerConnection(String crmSite, bool ssl)
        {
            //read the information from config file for CRM ROOT URL 
            config.ServerAddress = crmSite;
            config.ssl = ssl;

            //set the credentials 
            ClientCredentials defaultCreds = new ClientCredentials();
            defaultCreds.Windows.ClientCredential = CredentialCache.DefaultNetworkCredentials;

            config.EndpointType = AuthenticationProviderType.ActiveDirectory;

            //call getserverconfig, etc to set up the configuration 
            GetServerConfiguration();

            //create the OrgServiceProxy
            OrgServiceProxy = GetOrgServiceProxy();

        }

        /// <summary>
        /// Secondary constructor - can use federation, uses default creds, takes the server and ssl flag as input 
        /// </summary>
        public ServerConnection(String crmSite, bool ssl, AuthenticationProviderType authType)
        {
            //read the information from config file for CRM ROOT URL 
            config.ServerAddress = crmSite;
            config.ssl = ssl;
            config.EndpointType = authType;

            //set the credentials 
            ClientCredentials defaultCreds = new ClientCredentials();
            defaultCreds.Windows.ClientCredential = CredentialCache.DefaultNetworkCredentials;
            
            //call getserverconfig, etc to set up the configuration 
            GetServerConfiguration();

            //create the OrgServiceProxy
            OrgServiceProxy = GetOrgServiceProxy();

        }

        /// <summary>
        /// Advanced constructor - for SSL, CRM Online, or when you want to pass in credentials other
        /// than the defaultcredentials.
        /// </summary>
        /// <param name="crmSite">'orgname.crm.dynamics.com' (crm online) or 'server/orgname' (on premis) </param>
        /// <param name="ssl">is the site SSL?</param>
        /// <param name="user">LiveId or domain/user</param>
        /// <param name="password">password</param>
        /// <param name="authType">indicate which authentication approach to use</param>
        public ServerConnection(string crmSite, bool ssl, string user, string password, AuthenticationProviderType authType)
        {
            config.ServerAddress = crmSite;
            config.ssl = ssl;
            config.user = user;
            config.password = password;
            config.EndpointType = authType;

            GetServerConfiguration();

            OrgServiceProxy = GetOrgServiceProxy();
        }

        /// <summary>
        /// Sets up the server connection information including the target organization's
        /// Uri and user login credentials.
        /// </summary>
        public virtual Configuration GetServerConfiguration()
        {

            // One of the Microsoft Dynamics CRM Online data centers.
            if (config.ServerAddress.Contains(".dynamics.com"))
            {
                // Set or get the device credentials. Required for Windows Live ID authentication. 
                config.DeviceCredentials = GetDeviceCredentials();

                config.OrganizationUri = new Uri(String.Format("https://{0}/XRMServices/2011/Organization.svc", config.ServerAddress));

            }

            // Does the server use Secure Socket Layer (https)?
            else if (config.ssl)
                config.OrganizationUri =
                    new Uri(String.Format("https://{0}/XRMServices/2011/Organization.svc", config.ServerAddress));

            else
                config.OrganizationUri =
                    new Uri(String.Format("http://{0}/XRMServices/2011/Organization.svc", config.ServerAddress));

            // Get the user's logon credentials.
            config.Credentials = GetUserLogonCredentials();

            return config;
        }

        #endregion Public methods

        #region Protected methods

        /// <summary>
        /// Builds the user's logon credentials for the target server.
        /// </summary>
        /// <returns>Logon credentials of the user.</returns>
        protected virtual ClientCredentials GetUserLogonCredentials()
        {
            ClientCredentials credentials = new ClientCredentials(); ;
            String userName;
            String password;
            String domain;

            //if we already have used defaultcredentials, user config field will be empty
            if (config.user.Length == 0)
                return config.Credentials;

            if (config.EndpointType == AuthenticationProviderType.ActiveDirectory)
            {
                String[] domainAndUserName;

                do
                {
                    domainAndUserName = config.user.Split('\\');

                    if (domainAndUserName.Length == 1 && String.IsNullOrWhiteSpace(domainAndUserName[0]))
                    {
                        return null;
                    }
                }
                while (domainAndUserName.Length != 2 || String.IsNullOrWhiteSpace(domainAndUserName[0]) || String.IsNullOrWhiteSpace(domainAndUserName[1]));

                domain = domainAndUserName[0];
                userName = domainAndUserName[1];

                password = config.password;

                credentials.Windows.ClientCredential = new System.Net.NetworkCredential(userName, password, domain);
            }
            else if (config.EndpointType == AuthenticationProviderType.Federation)
            {
                userName = config.user;
                if (string.IsNullOrWhiteSpace(userName))
                {
                    return null;
                }

                password = config.password;

                credentials.UserName.UserName = userName;
                credentials.UserName.Password = password;
            }
            else
                return null;

            return credentials;
        }

        /// <summary>
        /// Create an organization service proxy that can be used by the client to 
        /// invoke calls against the CRM API.
        /// </summary>
        /// <returns>A working organization service proxy</returns>
        protected OrganizationServiceProxy GetOrgServiceProxy()
        {
            OrganizationServiceProxy temp = new OrganizationServiceProxy(config.OrganizationUri, config.HomeRealmUri, config.Credentials, config.DeviceCredentials);
            temp.ServiceConfiguration.CurrentServiceEndpoint.Behaviors.Add(new ProxyTypesBehavior());
            return temp;
        }

        /// <summary>
        /// Used directly from the SDK sample code. Sets up the 'device' credentials
        /// required with LiveId
        /// </summary>
        /// <returns></returns>
        protected virtual ClientCredentials GetDeviceCredentials()
        {
            return CRM2011Helpers.DeviceIdManager.LoadOrRegisterDevice();
        }
        #endregion Private methods
    }
}
