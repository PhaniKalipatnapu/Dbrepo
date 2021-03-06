/****** Object:  StoredProcedure [dbo].[POBL_RETRIEVE_S3]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[POBL_RETRIEVE_S3]
	(
	 @An_Case_IDNO		NUMERIC(6,0)
    )
AS
/*
 *     PROCEDURE NAME    : POBL_RETRIEVE_S3
 *     DESCRIPTION       : It retreive the obligation details from POBL_Y1 which are not in OBLE_Y1
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 08-MAR-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN	
		DECLARE
			@Lc_Yes_INDC		CHAR(1) = 'Y',
			@Lc_ProcessS_CODE	CHAR(1) = 'S',
			@Lc_ProcessL_CODE	CHAR(1) = 'L',
			@Lc_TypeDebtGT_CODE CHAR(2) = 'GT',
			@Ld_High_DATE		DATE	= '12/31/9999';
   
			SELECT  B.Record_NUMB,
					B.TypeDebt_CODE,					
					B.Periodic_AMNT,
					B.FreqPeriodic_CODE AS Frequency_CODE ,
					B.Effective_DATE,
					B.End_DATE AS EndObligation_DATE,	
					B.CheckRecipient_ID AS FundsRecipient_ID,
					B.PayBack_INDC 
			  FROM PSRD_Y1 S
				   JOIN POBL_Y1 B
			    ON S.RECORD_NUMB = B.RECORD_NUMB
			 WHERE S.CASE_IDNO = @An_Case_IDNO
			   AND S.Process_CODE = @Lc_ProcessS_CODE
			   AND B.Process_CODE = @Lc_ProcessL_CODE
			   AND B.TypeDebt_CODE <>  @Lc_TypeDebtGT_CODE
			   AND B.PayBack_INDC <> @Lc_Yes_INDC 
			AND NOT EXISTS (SELECT 1 
							  FROM OBLE_Y1  O
							 WHERE O.CASE_IDNO		 = S.CASE_IDNO
							   AND O.TYPEDEBT_CODE	 = B.TYPEDEBT_CODE							   
							   AND O.ENDVALIDITY_DATE = @Ld_High_DATE) 
			ORDER BY B.TypeDebt_CODE;

END; --End of POBL_RETRIEVE_S3;


GO
