/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S6]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S6]  
(
     @An_Case_IDNO		         NUMERIC(6,0),
     @An_OrderSeq_NUMB		     NUMERIC(2,0),
     @An_ObligationSeq_NUMB		 NUMERIC(2,0),
     @Ad_BeginObligation_DATE	 DATE	       OUTPUT,
     @An_MemberMci_IDNO		     NUMERIC(10,0) OUTPUT,
     @Ac_TypeDebt_CODE		     CHAR(2)	   OUTPUT,
     @Ac_Fips_CODE		         CHAR(7)	   OUTPUT,
     @Ac_FreqPeriodic_CODE		 CHAR(1)       OUTPUT,
     @An_Periodic_AMNT           NUMERIC(11,2) OUTPUT,
     @Ad_EndObligation_DATE		 DATE	       OUTPUT,
     @Ac_Last_NAME               CHAR(20)      OUTPUT,
     @Ac_First_NAME              CHAR(16)      OUTPUT,
     @Ac_Middle_NAME             CHAR(20)      OUTPUT, 
     @Ac_Suffix_NAME             CHAR(4)       OUTPUT,
     @An_MemberSsn_NUMB		     NUMERIC(9,0)  OUTPUT,
     @Ac_StatusCase_CODE         CHAR(1)       OUTPUT,
     @Ac_RespondInit_CODE        CHAR(1)       OUTPUT,
     @Ac_TypeCase_CODE           CHAR(1)       OUTPUT
     )
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S6
 *     DESCRIPTION       : Procedure to populate the header information elements in the screen.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 02-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
 BEGIN

      SELECT @Ac_FreqPeriodic_CODE = NULL,
			 @Ad_BeginObligation_DATE = NULL,
			 @Ad_EndObligation_DATE = NULL,
			 @An_Periodic_AMNT = NULL,
			 @Ac_TypeDebt_CODE = NULL,
			 @An_MemberMci_IDNO = NULL,
			 @An_MemberSsn_NUMB = NULL,
			 @Ac_Fips_CODE = NULL,
			 @Ac_Last_NAME = NULL,
             @Ac_Suffix_NAME = NULL,
             @Ac_First_NAME = NULL,
             @Ac_Middle_NAME = NULL,
             @Ac_StatusCase_CODE = NULL,
             @Ac_RespondInit_CODE = NULL,
             @Ac_TypeCase_CODE = NULL;
			 
     DECLARE @Li_Zero_NUMB		SMALLINT =0,
			 @Ld_Current_DATE	DATE = DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME(),
			 @Ld_High_DATE		DATE= '12/31/9999';
			 
      SELECT @An_MemberMci_IDNO = a.MemberMci_IDNO, 
             @Ac_Last_NAME = D.Last_NAME,
             @Ac_Suffix_NAME = D.Suffix_NAME,
             @Ac_First_NAME = D.First_NAME,
             @Ac_Middle_NAME = D.Middle_NAME,
             @An_MemberSsn_NUMB =ISNULL(D.MemberSsn_NUMB, @Li_Zero_NUMB),
             @Ac_TypeDebt_CODE = a.TypeDebt_CODE, 
             @Ac_Fips_CODE = a.Fips_CODE, 
             @An_Periodic_AMNT = a.Periodic_AMNT, 
             @Ac_FreqPeriodic_CODE = a.FreqPeriodic_CODE, 
             @Ad_BeginObligation_DATE = a.BeginObligation_DATE, 
             @Ad_EndObligation_DATE = a.EndObligation_DATE,
             @Ac_StatusCase_CODE = c.StatusCase_CODE,
             @Ac_RespondInit_CODE = c.RespondInit_CODE,
             @Ac_TypeCase_CODE = c.TypeCase_CODE             
        FROM OBLE_Y1 a
			 LEFT OUTER JOIN
		     DEMO_Y1 D
          ON D.MemberMci_IDNO = a.MemberMci_IDNO
             JOIN
             CASE_Y1 c
          ON a.Case_IDNO = c.Case_IDNO 
       WHERE a.Case_IDNO = @An_Case_IDNO 
         AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
         AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB 
         AND (     (     a.BeginObligation_DATE <= @Ld_Current_DATE 
					AND a.EndObligation_DATE = 
									   (
										SELECT MAX(b.EndObligation_DATE)
										  FROM OBLE_Y1 b
										 WHERE b.Case_IDNO = a.Case_IDNO 
										   AND b.OrderSeq_NUMB = a.OrderSeq_NUMB 
										   AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB 
										   AND b.BeginObligation_DATE <= @Ld_Current_DATE 
										   AND b.EndValidity_DATE = @Ld_High_DATE
										)      
					) 
				OR  (    a.BeginObligation_DATE > @Ld_Current_DATE 
				     AND a.EndObligation_DATE = 
									   (
											SELECT MIN(b.EndObligation_DATE)
											  FROM OBLE_Y1 b
											 WHERE b.Case_IDNO = a.Case_IDNO 
											   AND b.OrderSeq_NUMB = a.OrderSeq_NUMB 
											   AND b.ObligationSeq_NUMB = a.ObligationSeq_NUMB 
											   AND b.BeginObligation_DATE > @Ld_Current_DATE 
											   AND b.EndValidity_DATE = @Ld_High_DATE
									    ) 
					 AND NOT EXISTS 
						              (
										SELECT 1 
										  FROM OBLE_Y1 c
										 WHERE c.Case_IDNO = a.Case_IDNO 
										   AND c.OrderSeq_NUMB = a.OrderSeq_NUMB 
										   AND c.ObligationSeq_NUMB = a.ObligationSeq_NUMB 
										   AND c.BeginObligation_DATE <= @Ld_Current_DATE 
										   AND c.EndValidity_DATE = @Ld_High_DATE
						               )
					)
		     ) 
         AND a.EndValidity_DATE = @Ld_High_DATE;

END;--End of OBLE_RETRIEVE_S6 


GO
