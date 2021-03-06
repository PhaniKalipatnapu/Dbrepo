/****** Object:  StoredProcedure [dbo].[OBLE_RETRIEVE_S127]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 CREATE PROCEDURE [dbo].[OBLE_RETRIEVE_S127]    
 (  
     @An_Case_IDNO    NUMERIC(6,0),  
     @An_OrderSeq_NUMB   NUMERIC(2,0),       
     @Ac_TypeDebt_CODE	VARCHAR(2),
     @An_MemberMci_IDNO		NUMERIC(10,0),
	 @Ac_Fips_CODE		CHAR(7),
     @An_ObligationSeq_NUMB  NUMERIC(2,0)  OUTPUT  
    )  
AS  
/*  
 *     PROCEDURE NAME    : OBLE_RETRIEVE_S127  
 *     DESCRIPTION       : Retrieve the maximum Obligation sequence number from OBLE_Y1 for Case_ID and Debt Type combination.  
 *     DEVELOPED BY      : IMP Team  
 *     DEVELOPED ON      : 19-DEC-2011  
 *     MODIFIED BY       :   
 *     MODIFIED ON       :   
 *     VERSION NO        : 1  
*/  
   BEGIN  
  
      SET @An_ObligationSeq_NUMB = NULL;  
  
      DECLARE 
			@Li_Zero_NUMB SMALLINT = 0,
			@Ld_High_DATE DATE = '9999-12-31';
      
      SELECT @An_ObligationSeq_NUMB = ISNULL(MAX(O.ObligationSeq_NUMB), @Li_Zero_NUMB)
      FROM OBLE_Y1 O
      WHERE O.Case_IDNO = @An_Case_IDNO   
       AND  O.OrderSeq_NUMB = @An_OrderSeq_NUMB
        AND O.TypeDebt_CODE =@Ac_TypeDebt_CODE
        AND O.MemberMci_IDNO = @An_MemberMci_IDNO
		AND O.Fips_CODE = @Ac_Fips_CODE
		--Bug 13581 - After overwriting FIPS on OWIZ when entering a new obligation for original FIPS an obligation 2 isn't created - Starts
		AND O.EndValidity_DATE = @Ld_High_DATE
		--Bug 13581 - After overwriting FIPS on OWIZ when entering a new obligation for original FIPS an obligation 2 isn't created - Ends
                    
END; --END OF OBLE_RETRIEVE_S42  
  
GO
