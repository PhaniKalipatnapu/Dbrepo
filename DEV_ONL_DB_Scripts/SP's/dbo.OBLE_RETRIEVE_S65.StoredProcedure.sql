/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S65]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S65]  
(
     @An_Case_IDNO							NUMERIC(6,0),
     @An_OrderSeq_NUMB						NUMERIC(2,0),
     @An_ObligationSeq_NUMB					NUMERIC(2,0),
     @Ad_BeginObligation_DATE				DATE,
     @Ac_TypeDebt_CODE						CHAR(2),
     @Ac_Fips_CODE							CHAR(7),
     @Ac_Allocated_INDC						CHAR(1),
     @Ad_EndObligation_DATE					DATE	 OUTPUT
)
AS

/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S65
 *     DESCRIPTION       : Retrieve the contiguous obligation end date from OBLE_Y1 while obligation is modifying.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 23-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN

         SET @Ad_EndObligation_DATE = NULL;

     DECLARE @Lc_No_INDC	CHAR(1) = 'N', 
             @Lc_Yes_INDC	CHAR(1) = 'Y', 
             @Ld_High_DATE	DATE	= '12/31/9999';
        
      SELECT DISTINCT @Ad_EndObligation_DATE = a.EndObligation_DATE
        FROM OBLE_Y1  a
       WHERE a.Case_IDNO = @An_Case_IDNO 
         AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
         AND ( ( @Ac_Allocated_INDC = @Lc_Yes_INDC 
				 AND a.ObligationSeq_NUMB = @An_ObligationSeq_NUMB ) 
			  OR( @Ac_Allocated_INDC = @Lc_No_INDC
				  AND a.TypeDebt_CODE = @Ac_TypeDebt_CODE 
				  AND a.Fips_CODE = @Ac_Fips_CODE ) )
         AND a.BeginObligation_DATE = (	SELECT MAX(b.BeginObligation_DATE) 
											FROM OBLE_Y1  b
										WHERE b.Case_IDNO = a.Case_IDNO 
										  AND b.TypeDebt_CODE = a.TypeDebt_CODE 
										  AND b.MemberMci_IDNO = a.MemberMci_IDNO 
										  AND b.BeginObligation_DATE < @Ad_BeginObligation_DATE 
										  AND b.EndValidity_DATE = @Ld_High_DATE ) 
         AND a.EndValidity_DATE = @Ld_High_DATE;
                  
END;--End of OBLE_RETRIEVE_S65


GO
