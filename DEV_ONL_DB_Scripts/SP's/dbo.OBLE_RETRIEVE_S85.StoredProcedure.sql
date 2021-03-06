/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S85]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S85] (
	 @An_Case_IDNO					NUMERIC(6,0),
	 @An_OrderSeq_NUMB				NUMERIC(2,0),
	 @Ad_BeginObligation_DATE		DATE,
     @An_EventGlobalBeginSeq_NUMB	NUMERIC(19,0),
     @An_MemberMci_IDNO				NUMERIC(10,0),
     @Ac_TypeDebt_CODE				CHAR(2),
     @Ac_Fips_CODE					CHAR(7),
     @Ai_Count_QNTY                 INT			OUTPUT
    )
AS

/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S85
 *     DESCRIPTION       : This procedure is used to retrieve the count of obligation from OBLE_Y1.
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 22-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
      SET @Ai_Count_QNTY = NULL;

      DECLARE
        @Ld_High_DATE	DATE	= '12/31/9999';
        
      SELECT @Ai_Count_QNTY = COUNT(1)
		FROM OBLE_Y1 O
      WHERE O.Case_IDNO = @An_Case_IDNO 
        AND O.OrderSeq_NUMB = @An_OrderSeq_NUMB 
        AND O.TypeDebt_CODE = @Ac_TypeDebt_CODE 
        AND O.Fips_CODE = @Ac_Fips_CODE 
        AND O.MemberMci_IDNO = @An_MemberMci_IDNO 
        AND O.BeginObligation_DATE = @Ad_BeginObligation_DATE 
        AND O.EventGlobalBeginSeq_NUMB = @An_EventGlobalBeginSeq_NUMB 
        AND O.EndValidity_DATE =@Ld_High_DATE;
                 
END; --END OF OBLE_RETRIEVE_S85 


GO
