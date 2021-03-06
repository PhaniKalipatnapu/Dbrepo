/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S39]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S39] (
     @An_Case_IDNO		 NUMERIC(6,0),
     @An_OrderSeq_NUMB	 NUMERIC(2,0),
     @Ac_TypeDebt_CODE	 CHAR(2),
     @Ac_Fips_CODE		 CHAR(7)               
    )
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S39
 *     DESCRIPTION       : This procedure return the obligation's case id and member id 
 *     DEVELOPED BY      : Imp Team
 *     DEVELOPED ON      : 02-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN   
      DECLARE
		 @Li_One_NUMB		SMALLINT = 1,
		 @Ld_LastDay_DATE	DATE,
         @Ld_High_DATE		DATE	= '12/31/9999',
         @Ld_Current_DATE	DATE	= DBO.BATCH_COMMON_SCALAR$SF_SYS_DATE_TIME();
         
        SET @Ld_LastDay_DATE = DATEADD(M,@Li_One_NUMB, @Ld_Current_DATE);
        SET @Ld_LastDay_DATE = DATEADD(D, -DAY(@Ld_LastDay_DATE), @Ld_LastDay_DATE);
        
        SELECT DISTINCT a.Case_IDNO, 
						a.OrderSeq_NUMB, 
						a.ObligationSeq_NUMB, 
						a.MemberMci_IDNO
			FROM OBLE_Y1 a
		WHERE a.Case_IDNO = @An_Case_IDNO 
		AND   a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
		AND   a.TypeDebt_CODE = @Ac_TypeDebt_CODE 
		AND   a.Fips_CODE = @Ac_Fips_CODE 
		AND   a.BeginObligation_DATE <= @Ld_LastDay_DATE
		AND   a.EndValidity_DATE = @Ld_High_DATE;                  

END;--end of OBLE_RETRIEVE_S39


GO
