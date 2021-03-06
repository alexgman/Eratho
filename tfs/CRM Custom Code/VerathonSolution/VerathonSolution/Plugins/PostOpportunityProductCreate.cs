// <copyright file="PostOpportunityProductCreate.cs" company="Microsoft">
// Copyright (c) 2012 All Rights Reserved
// </copyright>
// <author>Microsoft</author>
// <date>10/30/2012 2:50:58 PM</date>
// <summary>Implements the PostOpportunityProductCreate Plugin.</summary>
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
    /// PostOpportunityProductCreate Plugin.
    /// </summary>    
    public class PostOpportunityProductCreate: Plugin
    {
        /// <summary>
        /// Alias of the image registered for the snapshot of the 
        /// primary entity's attributes after the core platform operation executes.
        /// The image contains the following attributes:
        /// No Attributes
        /// 
        /// Note: Only synchronous post-event and asynchronous registered plug-ins 
        /// have PostEntityImages populated.
        /// </summary>
        private readonly string postImageAlias = "postImage";

        /// <summary>
        /// Initializes a new instance of the <see cref="PostOpportunityProductCreate"/> class.
        /// </summary>
        public PostOpportunityProductCreate()
            : base(typeof(PostOpportunityProductCreate))
        {
            base.RegisteredEvents.Add(new Tuple<int, string, string, Action<LocalPluginContext>>(40, "Create", "opportunityproduct", new Action<LocalPluginContext>(ExecutePostOpportunityProductCreate)));

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
        
        protected void ExecutePostOpportunityProductCreate(LocalPluginContext localContext)
        {
            if (localContext.PluginExecutionContext.Depth >= 2)
            {
                return;
            }

            if (localContext == null)
            {
                throw new ArgumentNullException("localContext");
            }

            IPluginExecutionContext context = localContext.PluginExecutionContext;

            Entity postImageEntity = (context.PostEntityImages != null && context.PostEntityImages.Contains(this.postImageAlias)) ? context.PostEntityImages[this.postImageAlias] : null;

            try
            {
                IOrganizationService service = localContext.OrganizationService;
                Entity target = (Entity)localContext.PluginExecutionContext.InputParameters["Target"];
                XrmServiceContext crm = new XrmServiceContext(localContext.OrganizationService);

                Helper.ProcessProduct(service, postImageEntity, target, crm, "opportunityproduct");
            }
            catch
            {
            }
        }
    }
}
