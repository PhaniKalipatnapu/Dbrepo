/****** Object:  StoredProcedure [dbo].[DISH_RETRIEVE_S4]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DISH_RETRIEVE_S4] (
	 @An_CasePayorMCI_IDNO		 NUMERIC(10,0)	    ,
     @Ac_TypeHold_CODE		 	 CHAR(1)	  	    ,
     @Ac_SourceHold_CODE		 CHAR(2)	  	    ,
	 @Ac_ReasonHold_CODE		 CHAR(4)			,
     @Ad_Effective_DATE			 DATE		  	    ,
     @Ad_Expiration_DATE		 DATE		  	    ,  
     @Ai_Count_QNTY       		 INT          OUTPUT 
     )
AS

/*
*      PROCEDURE NAME    : DISH_RETRIEVE_S4
 *     DESCRIPTION       : Retrieve record count for a CasePayorMci Idno, type hold code, SourceHold Code and the effective & expiration date
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 20-SEP-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
*/

   BEGIN

      SET @Ai_Count_QNTY = NULL;

      DECLARE
         @Ld_High_DATE DATE = '12/31/9999',
		  @Lc_SourceHoldDH_CODE	CHAR(2)='DH';
        
 		SELECT @Ai_Count_QNTY = COUNT(1)
 		 FROM DISH_Y1 a
 		WHERE a.CasePayorMCI_IDNO = @An_CasePayorMCI_IDNO
 		  AND a.TypeHold_CODE = @Ac_TypeHold_CODE
 		  AND (a.SourceHold_CODE = @Ac_SourceHold_CODE
		   OR (a.ReasonHold_CODE = @Ac_ReasonHold_CODE 
		  AND a.SourceHold_CODE = @Lc_SourceHoldDH_CODE))
 		  AND (   (@Ad_Effective_DATE < a.Effective_DATE)
 		       OR (@Ad_Expiration_DATE BETWEEN a.Effective_DATE AND a.Expiration_DATE
 		          )
 		       OR (a.Effective_DATE > @Ad_Effective_DATE)
 		       OR (    a.Expiration_DATE > @Ad_Effective_DATE
 		           AND a.Expiration_DATE < @Ad_Expiration_DATE
 		          )
 		      )
 		  AND a.EndValidity_DATE = @Ld_High_DATE;

                  
END;    --End of DISH_RETRIEVE_S4


GO
