// <copyright file="PostProductRetrieveMultiple.cs" company="Microsoft">
// Copyright (c) 2012 All Rights Reserved
// </copyright>
// <author>Microsoft</author>
// <date>11/2/2012 11:13:31 AM</date>
// <summary>Implements the PostProductRetrieveMultiple Plugin.</summary>
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.1
// </auto-generated>
namespace VerathonSolution.Plugins
{
    using System;
    using System.ServiceModel;
    using System.Linq;
    using System.Collections.Generic;

    using Microsoft.Xrm.Sdk;

    using Verathon.Crm.Entities;
    using Verathon.Crm.Helper;

    /// <summary>
    /// PostProductRetrieveMultiple Plugin.
    /// </summary>    
    public class PostProductRetrieveMultiple: Plugin
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="PostProductRetrieveMultiple"/> class.
        /// </summary>
        public PostProductRetrieveMultiple()
            : base(typeof(PostProductRetrieveMultiple))
        {
            base.RegisteredEvents.Add(new Tuple<int, string, string, Action<LocalPluginContext>>(40, "RetrieveMultiple", "product", new Action<LocalPluginContext>(ExecutePostProductRetrieveMultiple)));

            // Note : you can register for more events here if this plugin is not specific to an individual entity and message combination.
            // You may also need to update your RegisterFile.crmregister plug-in registration file to reflect any change.
        }

        /// <summary>
        /// Executes the plug-in.
        /// </summary>
        /// <param name="localContext">The <see cref="LocalPluginContext"/> which contains the
        /// <see cref="IPluginExecutionContext"/>,
        /// <see cref="IOrganizationService"/>
        /// and <see cref="ITracingService"/>
        /// </param>
        /// <remarks>
        /// For improved performance, Microsoft Dynamics CRM caches plug-in instances.
        /// The plug-in's Execute method should be written to be stateless as the constructor
        /// is not called for every invocation of the plug-in. Also, multiple system threads
        /// could execute the plug-in at the same time. All per invocation state information
        /// is stored in the context. This means that you should not use global variables in plug-ins.
        /// </remarks>
        protected void ExecutePostProductRetrieveMultiple(LocalPluginContext localContext)
        {
            if (localContext == null)
            {
                throw new ArgumentNullException("localContext");
            }

            IPluginExecutionContext context = localContext.PluginExecutionContext;

            XrmServiceContext vth = new XrmServiceContext();


            EntityCollection ecBusEntCol = (EntityCollection)context.OutputParameters["BusinessEntityCollection"];

            foreach (Entity ent in ecBusEntCol.Entities)
            {
                //phone = acct["relatedcontact.telephone1"].ToString();
                //test = ((AliasedValue)ent.Attributes["vth_cmfr"]).Value.ToString();
                ent.Attributes["name"] = (string)ent.Attributes["vth_cmfr"];
            }
        }
    }
}
