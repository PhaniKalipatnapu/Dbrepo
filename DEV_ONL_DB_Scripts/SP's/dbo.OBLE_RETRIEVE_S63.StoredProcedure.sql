/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S63]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [dbo].[OBLE_RETRIEVE_S63] (
      @An_Case_IDNO					NUMERIC(6,0),
      @An_OrderSeq_NUMB				NUMERIC(2,0),
      @Ad_BeginObligation_DATE		DATE,
      @An_MemberMci_IDNO			NUMERIC(10,0),
      @Ac_TypeDebt_CODE				CHAR(2),
      @Ac_Fips_CODE					CHAR(7),
      @Ad_EndObligation_DATE		DATE,
      @Ac_Allocated_INDC			CHAR(1)     
      
     )
AS
/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S63
 *     DESCRIPTION       : This procedure returns periodic amnt for checking a duplication while an obligation modification.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 17-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
      DECLARE
         @Lc_No_INDC		CHAR(1) = 'N', 
         @Lc_Yes_INDC		CHAR(1) = 'Y', 
         @Ld_High_DATE		DATE	= '12/31/9999';
        
      SELECT a.Periodic_AMNT
		FROM OBLE_Y1 a
      WHERE a.Case_IDNO = @An_Case_IDNO 
        AND a.OrderSeq_NUMB = @An_OrderSeq_NUMB 
        AND a.TypeDebt_CODE = @Ac_TypeDebt_CODE 
        AND a.Fips_CODE != @Ac_Fips_CODE 
        AND ( @Ac_Allocated_INDC = @Lc_No_INDC 
             OR (@Ac_Allocated_INDC = @Lc_Yes_INDC 
					AND a.MemberMci_IDNO = @An_MemberMci_IDNO)) 
	    AND (@Ad_BeginObligation_DATE BETWEEN a.BeginObligation_DATE AND a.EndObligation_DATE 
			  OR @Ad_EndObligation_DATE BETWEEN a.BeginObligation_DATE AND a.EndObligation_DATE) 
	    AND a.EndValidity_DATE = @Ld_High_DATE;
                  
END; --END OF OBLE_RETRIEVE_S63


GO
