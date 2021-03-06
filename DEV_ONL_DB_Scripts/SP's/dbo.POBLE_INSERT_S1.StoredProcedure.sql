/****** Object:  StoredProcedure [dbo].[POBLE_INSERT_S1]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[POBLE_INSERT_S1]  
(
     @An_Case_IDNO					NUMERIC(6,0),
     @An_OrderSeq_NUMB				NUMERIC(2,0),
     @An_ObligationSeq_NUMB			NUMERIC(2,0),
     @Ad_BeginObligation_DATE		DATE,
     @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0),
     @Ac_Session_ID					CHAR(30),
     @An_MemberMci_IDNO				NUMERIC(10,0),
     @Ac_TypeDebt_CODE				CHAR(2),
     @Ac_Fips_CODE					CHAR(7),
     @Ac_FreqPeriodic_CODE			CHAR(1),
     @An_Periodic_AMNT				NUMERIC(11,2),
     @An_ExpectToPay_AMNT			NUMERIC(11,2),
     @Ac_ReasonChng_CODE			CHAR(2),
     @Ad_EndObligation_DATE			DATE,
     @Ad_AccrualLast_DATE			DATE,
     @Ad_AccrualNext_DATE			DATE,
     @Ac_CheckRecipient_ID		    CHAR(10),
     @Ac_CheckRecipient_CODE		CHAR(1),    
     @An_EventGlobalEndSeq_NUMB		NUMERIC(19,0),
     @Ad_BeginValidity_DATE			DATE,
     @Ad_EndValidity_DATE			DATE,
     @Ac_ExpectToPay_CODE			CHAR(1),
     @Ac_SignedOnWorker_ID		    CHAR(30)
)
AS

/*
 *     PROCEDURE NAME    : POBLE_INSERT_S1
 *     DESCRIPTION       : INSERT THE OBLIGATION DETAILS INTO TEMPORVARY TABLE POBLE_T1 FOR POP UP WINDOW.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 22-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

    BEGIN 
	DECLARE
		@Li_ArrearInit_AMNT		SMALLINT  = 0;
		
    INSERT POBLE_Y1
				(
				 Case_IDNO, 
				 OrderSeq_NUMB, 
				 ObligationSeq_NUMB, 
				 MemberMci_IDNO, 
				 TypeDebt_CODE, 
				 Fips_CODE, 
				 FreqPeriodic_CODE, 
				 Periodic_AMNT,
				 ArrearInit_AMNT,
				 ExpectToPay_AMNT, 
				 ReasonChng_CODE, 
				 BeginObligation_DATE, 
				 EndObligation_DATE, 
				 AccrualLast_DATE, 
				 AccrualNext_DATE, 
				 CheckRecipient_ID, 
				 CheckRecipient_CODE, 
				 EventGlobalBeginSeq_NUMB, 
				 EventGlobalEndSeq_NUMB, 
				 BeginValidity_DATE, 
				 EndValidity_DATE, 
				 ExpectToPay_CODE, 
				 Worker_ID, 
				 Session_ID
				 )
         VALUES 
         (
            @An_Case_IDNO,					
            @An_OrderSeq_NUMB,				
            @An_ObligationSeq_NUMB,			
            @An_MemberMci_IDNO,				
            @Ac_TypeDebt_CODE,				
            @Ac_Fips_CODE,					
            @Ac_FreqPeriodic_CODE,			
            @An_Periodic_AMNT,
            @Li_ArrearInit_AMNT,				
            @An_ExpectToPay_AMNT,			
            @Ac_ReasonChng_CODE,			
            @Ad_BeginObligation_DATE,		
            @Ad_EndObligation_DATE,			
            @Ad_AccrualLast_DATE,			
            @Ad_AccrualNext_DATE,			
            @Ac_CheckRecipient_ID,			
            @Ac_CheckRecipient_CODE,		
            @An_EventGlobalBeginSeq_NUMB,	
            @An_EventGlobalEndSeq_NUMB,		
            @Ad_BeginValidity_DATE,			
            @Ad_EndValidity_DATE,			
            @Ac_ExpectToPay_CODE,			
            @Ac_SignedOnWorker_ID,			
            @Ac_Session_ID  				
           );

END;--End of POBLE_INSERT_S1


GO
