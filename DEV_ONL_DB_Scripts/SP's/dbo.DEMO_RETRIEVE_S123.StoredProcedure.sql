/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S123]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S123] (
 @An_Case_IDNO   NUMERIC(6, 0),
 @Ac_Last_NAME   CHAR(20) OUTPUT,
 @Ac_First_NAME  CHAR(16) OUTPUT,
 @Ac_Middle_NAME CHAR(20) OUTPUT
 )
AS
 /*    
  *     PROCEDURE NAME    : DEMO_RETRIEVE_S123    
  *     DESCRIPTION       : Retrieve the first Last Name, First Name, and Middle Name for a Case Idno, Case Relation is CP, Member Case Status is Active, and Member Idno that?s common between two tables.    
  *     DEVELOPED BY      : IMP Team 
  *     DEVELOPED ON      : 02-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
  */
 BEGIN
  SELECT @Ac_Last_NAME = NULL,
         @Ac_First_NAME = NULL,
         @Ac_Middle_NAME = NULL;

  DECLARE @Lc_CaseRelationshipCp_CODE     CHAR(1) = 'C',
          @Lc_CaseMemberStatusActive_CODE CHAR(1) = 'A';

  SELECT TOP 1 @Ac_Last_NAME = d.Last_NAME,
               @Ac_First_NAME = d.First_NAME,
               @Ac_Middle_NAME = d.Middle_NAME
    FROM DEMO_Y1 d
         JOIN CMEM_Y1 c
          ON d.MemberMci_IDNO = c.MemberMci_IDNO
   WHERE c.Case_IDNO = ISNULL(@An_Case_IDNO, c.Case_IDNO)
     AND c.CaseRelationship_CODE IN (@Lc_CaseRelationshipCp_CODE)
     AND c.CaseMemberStatus_CODE = @Lc_CaseMemberStatusActive_CODE;
 END; --End of DEMO_RETRIEVE_S123 

GO
