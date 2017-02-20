SELECT		COUNT(A.ClosedInteraction) ClosedInteractions
			, SUM(A.NewInteraction) NewInteractions
			, SUM(A.Referrals) Referrals
FROM		(SELECT		I.Id ClosedInteraction
						, CASE		WHEN COUNT(I2.Id) > 0 THEN 1 
									ELSE 0 END NewInteraction
						, CASE		WHEN MAX(FLA.referred_lead) > 0 THEN 1
									ELSE 0 END Referrals
						, CASE		WHEN IQ.InquiryType = 2 THEN 'Inbound'
									ELSE 'Outbound' END FollowUpType
			FROM		CallCenter.dbo.Interactions I
			LEFT JOIN	CallCenter.dbo.Interactions I2 
						ON I.Id != I2.Id
						AND I.ContactId = I2.ContactId 
						AND I2.CreatedOn BETWEEN I.CreatedOn AND DATEADD(DAY, 14, I.CreatedOn)
						AND I2.CreatedByInquiryId > 0
			LEFT JOIN	CallCenter.dbo.LKUP_InteractionStates LIS 
						ON I2.InteractionState = LIS.Id
			LEFT JOIN	CallCenter.dbo.WarmTransferProcess WTP 
						ON I2.ContactId = WTP.ContactId
			LEFT JOIN	EDW.dbo.fact_lead_activity FLA 
						ON WTP.LeadId = FLA.lead_id
						AND CONVERT(VARCHAR(10),WTP.CreatedOn,112) < dim_date_key_activity
			LEFT JOIN	CallCenter.dbo.Inquiries IQ ON I2.CreatedByInquiryId = IQ.Id 
			LEFT JOIN	(SELECT		OC2.InteractionId
									, OC2.DialOutcome
						FROM		(SELECT		OC.InteractionId
												, MAX(OC.Id) FinalCall
									FROM		CallCenter.dbo.OutboundCalls OC
									WHERE		OC.OccurredOn >= '2016-12-01'
									GROUP BY	InteractionId) OC
						LEFT JOIN	CallCenter.dbo.OutboundCalls OC2 
									ON OC.InteractionId = OC2.InteractionId 
									AND OC.FinalCall = OC2.Id) OC
						ON I.Id = OC.InteractionId
			WHERE		I.StateReason = 377
						AND I.CreatedOn BETWEEN '2016-12-01' AND '2017-01-31'
						AND OC.DialOutcome = 4
			GROUP BY	I.Id
						, CASE		WHEN IQ.InquiryType = 2 THEN 'Inbound'
									ELSE 'Outbound' END) A 




SELECT		FollowUpType
			, SUM(A.NewInteraction) NewInteractions
			, SUM(A.Referrals) Referrals
FROM		(SELECT		I.Id ClosedInteraction
						, CASE		WHEN COUNT(I2.Id) > 0 THEN 1 
									ELSE 0 END NewInteraction
						, CASE		WHEN MAX(FLA.referred_lead) > 0 THEN 1
									ELSE 0 END Referrals
						, CASE		WHEN IQ.InquiryType = 2 THEN 'Inbound'
									ELSE 'Outbound' END FollowUpType
			FROM		CallCenter.dbo.Interactions I
			LEFT JOIN	CallCenter.dbo.Interactions I2 
						ON I.Id != I2.Id
						AND I.ContactId = I2.ContactId 
						AND I2.CreatedOn BETWEEN I.CreatedOn AND DATEADD(DAY, 14, I.CreatedOn)
						AND I2.CreatedByInquiryId > 0
			LEFT JOIN	CallCenter.dbo.LKUP_InteractionStates LIS 
						ON I2.InteractionState = LIS.Id
			LEFT JOIN	CallCenter.dbo.WarmTransferProcess WTP 
						ON I2.ContactId = WTP.ContactId
			LEFT JOIN	EDW.dbo.fact_lead_activity FLA 
						ON WTP.LeadId = FLA.lead_id
						AND CONVERT(VARCHAR(10),WTP.CreatedOn,112) < dim_date_key_activity
			LEFT JOIN	CallCenter.dbo.Inquiries IQ ON I2.CreatedByInquiryId = IQ.Id 
			LEFT JOIN	(SELECT		OC2.InteractionId
									, OC2.DialOutcome
						FROM		(SELECT		OC.InteractionId
												, MAX(OC.Id) FinalCall
									FROM		CallCenter.dbo.OutboundCalls OC
									WHERE		OC.OccurredOn >= '2016-12-01'
									GROUP BY	InteractionId) OC
						LEFT JOIN	CallCenter.dbo.OutboundCalls OC2 
									ON OC.InteractionId = OC2.InteractionId 
									AND OC.FinalCall = OC2.Id) OC
						ON I.Id = OC.InteractionId
			WHERE		I.StateReason = 377
						AND I.CreatedOn BETWEEN '2016-12-01' AND '2017-01-31'
						AND OC.DialOutcome = 4
			GROUP BY	I.Id
						, CASE		WHEN IQ.InquiryType = 2 THEN 'Inbound'
									ELSE 'Outbound' END) A
GROUP BY	FollowUpType
ORDER BY	SUM(A.NewInteraction) DESC