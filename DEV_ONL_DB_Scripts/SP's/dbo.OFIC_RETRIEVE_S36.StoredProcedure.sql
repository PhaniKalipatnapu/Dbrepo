/****** Object:  StoredProcedure [dbo].[OFIC_RETRIEVE_S36]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OFIC_RETRIEVE_S36] ( 
			@An_Office_IDNO		 NUMERIC(3,0),
			@An_Case_IDNO		 NUMERIC(6,0),
			@Ac_WrkAccess_INDC   CHAR(1)	OUTPUT
		)
AS

/*
 *     PROCEDURE NAME    : OFIC_RETRIEVE_S36
 *     DESCRIPTION       : This procedure returns 'N' if the worker doesn't have case county previlege for a case level receipt. 
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 01-DEC-2011
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
      DECLARE @Lc_No_INDC		 CHAR(1) = 'N', 
			  @Ld_High_DATE		 DATE	 = '12/31/9999';
        
          SET @Ac_WrkAccess_INDC = 'Y';
        
       SELECT @Ac_WrkAccess_INDC = @Lc_No_INDC
		 FROM OFIC_Y1 a
        WHERE a.Office_IDNO		 = @An_Office_IDNO 
		  AND a.EndValidity_DATE = @Ld_High_DATE 
		  AND EXISTS (
						SELECT 1
						  FROM CASE_Y1 b
						 WHERE b.Case_IDNO   = @An_Case_IDNO 
						   AND b.County_IDNO <> a.County_IDNO );
                  
END; -- END OF OFIC_RETRIEVE_S36


GO
