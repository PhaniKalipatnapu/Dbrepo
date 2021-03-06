/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S134]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S134] (
 @Ac_CaseRelationship_CODE CHAR(1),
 @An_MemberMci_IDNO        NUMERIC(10),
 @An_Case_IDNO             NUMERIC(6),
 @Ac_Last_NAME             CHAR(20) OUTPUT,
 @Ac_First_NAME            CHAR(16) OUTPUT,
 @Ac_Middle_NAME           CHAR(20) OUTPUT,
 @Ac_Suffix_NAME           CHAR(4) OUTPUT
 )
AS
 /*                                                                                                                                                               
   *     PROCEDURE NAME    : DEMO_RETRIEVE_S134                                                                                                                         
   *     DESCRIPTION       : Retrieves the name of the respective member.                                                                                                 
   *     DEVELOPED BY      : IMP Team  
   *     DEVELOPED ON      : 02-NOV-2011                                                                                                                           
   *     MODIFIED BY       :                                                                                                                                       
   *     MODIFIED ON       :                                                                                                                                       
   *     VERSION NO        : 1                                                                                                                                     
  */
 BEGIN
  DECLARE @Lc_CaseRelationshipPf_CODE    CHAR(1) = 'P',
          @Lc_CaseRelationshipOther_CODE CHAR(1) = 'O';

  SELECT @Ac_Last_NAME = d.Last_NAME,
         @Ac_First_NAME = d.First_NAME,
         @Ac_Middle_NAME = d.Middle_NAME,
         @Ac_Suffix_NAME = d.Suffix_NAME
    FROM DEMO_Y1 d
         JOIN CMEM_Y1 c
          ON (d.MemberMci_IDNO = c.MemberMci_IDNO)
   WHERE ((@An_MemberMci_IDNO IS NULL
       AND c.CaseRelationship_CODE = @Ac_CaseRelationship_CODE
       AND c.Case_IDNO = @An_Case_IDNO)
       OR (@Ac_CaseRelationship_CODE IN (@Lc_CaseRelationshipOther_CODE, @Lc_CaseRelationshipPf_CODE)
           AND d.MemberMci_IDNO = @An_MemberMci_IDNO));
 END; -- End Of DEMO_RETRIEVE_S134                                                                                                                

GO
