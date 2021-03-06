/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S83]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S83] ( 
	  @An_Case_IDNO					NUMERIC(6,0),
	  @An_OrderSeq_NUMB				NUMERIC(2,0),
	  @An_MemberMci_IDNO			NUMERIC(10,0),
	  @Ac_TypeDebt_CODE				CHAR(2),
	  @Ac_Fips_CODE					CHAR(7),
	  @An_EventGlobalEndSeq_NUMB	NUMERIC(19,0),      
      @An_ObligationSeq_NUMB		NUMERIC(2,0)	 OUTPUT
    )
AS

/*
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S83
 *     DESCRIPTION       : This procedure returns the obligation sequence number for the case.
 *     DEVELOPED BY      : Imp Team
 *     DEVELOPED ON      : 02-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/
   BEGIN
      SET @An_ObligationSeq_NUMB = NULL;
      SELECT DISTINCT @An_ObligationSeq_NUMB = O.ObligationSeq_NUMB
		 FROM OBLE_Y1 O
      WHERE O.Case_IDNO = @An_Case_IDNO 
        AND O.OrderSeq_NUMB = @An_OrderSeq_NUMB 
        AND O.TypeDebt_CODE = @Ac_TypeDebt_CODE 
        AND O.Fips_CODE = @Ac_Fips_CODE 
        AND O.MemberMci_IDNO = @An_MemberMci_IDNO 
        AND O.EventGlobalEndSeq_NUMB = @An_EventGlobalEndSeq_NUMB;
                       
END;--end of OBLE_RETRIEVE_S83


GO
