/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S153]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S153] (  
			 @An_MemberMci_IDNO       NUMERIC(10,0),
			 @Ac_Exists_INDC           CHAR(1)		OUTPUT
			)
AS
/*
 *     PROCEDURE NAME    : CMEM_RETRIEVE_S153
 *     DESCRIPTION       : This procedure checks for the given MemberMci_IDNO is NCP or PutativeFather
 *						   Returns Y if it is NCP or PutativeFather
 *     DEVELOPED BY      : IMP Team
 *     DEVELOPED ON      : 01-JAN-2012
 *     MODIFIED BY       : 
 *     MODIFIED ON       : 
 *     VERSION NO        : 1
 */
BEGIN
     DECLARE @Lc_NcpRelationshipCase_CODE CHAR(1) = 'A', 
			 @Lc_PutativeFatherCaseRelationship_CODE CHAR(1) = 'P', 
			 @Lc_Yes_INDC CHAR(1) = 'Y',
			 @Lc_No_INDC  CHAR(1) = 'N';
     
		 SET @Ac_Exists_INDC = @Lc_No_INDC;
        
      SELECT TOP 1 @Ac_Exists_INDC = @Lc_Yes_INDC
        FROM CMEM_Y1 C
       WHERE C.MemberMci_IDNO = @An_MemberMci_IDNO 
         AND C.CaseRelationship_CODE IN ( @Lc_NcpRelationshipCase_CODE,  @Lc_PutativeFatherCaseRelationship_CODE);                  
END


GO
