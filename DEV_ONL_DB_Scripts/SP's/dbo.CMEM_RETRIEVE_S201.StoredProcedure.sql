/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S201]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S201] (
 @An_Case_IDNO        NUMERIC(6, 0),
 @Ac_Exists_INDC      CHAR(1) OUTPUT
 )
AS
 /*
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S201
  *     DESCRIPTION       : To check whether the case is a family voilence case
  *     DEVELOPED BY      : IMP Team
  *     DEVELOPED ON      : 10-AUG-2011
  *     MODIFIED BY       :
  *     MODIFIED ON       :
  *     VERSION NO        : 1
 */
 BEGIN

 	
 	DECLARE @Lc_Yes_INDC                CHAR(1) = 'Y',
 		    @Lc_No_INDC                 CHAR(1) = 'N',
 		    @Lc_CaseRelationshipA_CODE  CHAR(1) = 'A';
 		    
 		   	SET   @Ac_Exists_INDC = @Lc_No_INDC;  
 	
 	SELECT TOP 1  @Ac_Exists_INDC = @Lc_Yes_INDC
     FROM CMEM_Y1 B
    WHERE B.Case_IDNO = @An_Case_IDNO
     AND B.FamilyViolence_INDC=@Lc_Yes_INDC;
 
 END; -- END OF PROCEDURE CMEM_RETRIEVE_S201

GO
