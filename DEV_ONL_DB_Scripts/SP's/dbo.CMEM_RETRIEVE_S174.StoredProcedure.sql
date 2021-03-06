/****** Object:  StoredProcedure [dbo].[CMEM_RETRIEVE_S174]    Script Date: 4/10/2015 3:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[CMEM_RETRIEVE_S174] (  
 @An_Case_IDNO               NUMERIC(6, 0),  
 @An_MemberMci_IDNO          NUMERIC(10, 0),  
 @Ac_FamilyViolence_INDC     CHAR(1) OUTPUT
 )  
AS  
 /*  
  *     PROCEDURE NAME    : CMEM_RETRIEVE_S174  
  *     DESCRIPTION       : Retrieve the Family Violence Indicator for Case Id no , Member Id no & Case Status is Active or Inactive.  
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 11-MAY-2012
  *     MODIFIED BY       :   
  *     MODIFIED ON       :   
  *     VERSION NO        : 1  
 */  
 BEGIN  
  DECLARE @Lc_No_TEXT                CHAR(1) = 'N';
  
  SET @Ac_FamilyViolence_INDC = @Lc_No_TEXT;  
  
  SELECT @Ac_FamilyViolence_INDC = C.FamilyViolence_INDC
    FROM CMEM_Y1 C  
   WHERE C.Case_IDNO = @An_Case_IDNO  
     AND C.MemberMci_IDNO = @An_MemberMci_IDNO;     
 END;
  

GO
