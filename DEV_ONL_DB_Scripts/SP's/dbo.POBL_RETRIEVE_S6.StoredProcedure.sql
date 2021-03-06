/****** Object:  StoredProcedure [dbo].[POBL_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[POBL_RETRIEVE_S6]
	(
	 @Ac_TypeDebt_CODE			CHAR(2),
	 @An_Case_IDNO				NUMERIC(6,0),
	 @An_Record_NUMB			NUMERIC(19,0) OUTPUT,	 
	 @An_Payback_AMNT			NUMERIC(11,2) OUTPUT,
	 @Ac_FreqPeriodic_CODE		CHAR(1)		  OUTPUT,
	 @Ad_BeginObligation_DATE	DATE		  OUTPUT,
	 @Ac_PayBack_INDC			CHAR(1)       OUTPUT,
	 @Ac_ExpectToPay_CODE		CHAR(1)		  OUTPUT	 
    )
AS
/*
 *     PROCEDURE NAME    : POBL_RETRIEVE_S6
 *     DESCRIPTION       : It retreive the Payback details from POBL_Y1 which are not in OBLE_Y1
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 08-MAR-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN	
		SELECT 
			   @An_Record_NUMB			= NULL,			   	   
			   @An_Payback_AMNT			= NULL,
			   @Ac_FreqPeriodic_CODE	= NULL,
			   @Ad_BeginObligation_DATE	= NULL,
			   @Ac_PayBack_INDC			= NULL,
			   @Ac_ExpectToPay_CODE   = NULL;
			   		
		DECLARE
			@Lc_ProcessS_CODE	CHAR(1) = 'S',
			@Lc_ProcessL_CODE	CHAR(1) = 'L',
			@Lc_Yes_INDC		CHAR(1) = 'Y',
			@Ld_High_DATE		DATE	= '12/31/9999';
   
			SELECT @An_Record_NUMB	= B.Record_NUMB,				  
				   @An_Payback_AMNT = B.Periodic_AMNT,
				   @Ac_FreqPeriodic_CODE = B.FreqPeriodic_CODE,
				   @Ad_BeginObligation_DATE = B.Effective_DATE,
				   @Ac_PayBack_INDC	= B.PayBack_INDC,
				   @Ac_ExpectToPay_CODE = B.ReasonPayBack_CODE	    
			  FROM PSRD_Y1 S
				   JOIN POBL_Y1 B
			    ON S.RECORD_NUMB = B.RECORD_NUMB
			 WHERE S.CASE_IDNO = @An_Case_IDNO
			   AND B.TypeDebt_CODE = @Ac_TypeDebt_CODE
			   AND S.Process_CODE = @Lc_ProcessS_CODE
			   AND B.PayBack_INDC = @Lc_Yes_INDC
			   AND B.Process_CODE = @Lc_ProcessL_CODE
			   AND EXISTS (SELECT 1 
							  FROM OBLE_Y1  O
							 WHERE O.CASE_IDNO		 = S.CASE_IDNO
							   AND O.ENDVALIDITY_DATE = @Ld_High_DATE) ;
			
END; --End of POBL_RETRIEVE_S6;


GO
