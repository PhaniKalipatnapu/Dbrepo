/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S45]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S45] (
 @An_MemberMci_IDNO      NUMERIC(10, 0),
 @Ac_Last_NAME           CHAR(20) OUTPUT,
 @Ac_First_NAME          CHAR(16) OUTPUT,
 @Ac_Middle_NAME         CHAR(20) OUTPUT,
 @Ac_Suffix_NAME         CHAR(4) OUTPUT,
 @An_MemberSsn_NUMB      NUMERIC(9, 0) OUTPUT,
 @Ad_Birth_DATE          DATE OUTPUT,
 @Ac_Restricted_INDC     CHAR(1) OUTPUT,
 @Ac_StatusLocate_CODE   CHAR(1) OUTPUT,
 @Ac_FamilyViolence_INDC CHAR(1) OUTPUT
 )
AS
 /*    
  *     PROCEDURE NAME    : DEMO_RETRIEVE_S45    
  *     DESCRIPTION       : Retrieving Member Details.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 12-AUG-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  SELECT @Ac_Restricted_INDC = NULL,
         @Ac_FamilyViolence_INDC = NULL,
         @Ac_StatusLocate_CODE = NULL,
         @Ad_Birth_DATE = NULL,
         @An_MemberSsn_NUMB = NULL,
         @Ac_Last_NAME = NULL,
         @Ac_Suffix_NAME = NULL,
         @Ac_First_NAME = NULL,
         @Ac_Middle_NAME = NULL;

  DECLARE @Lc_Yes_INDC  CHAR(1) = 'Y',
		  @Lc_No_INDC   CHAR(1) = 'N',
          @Ld_High_DATE DATE = '12/31/9999';

  SELECT TOP 1 @Ac_Last_NAME = D.Last_NAME,
               @Ac_First_NAME = D.First_NAME,
               @Ac_Middle_NAME = D.Middle_NAME,
               @Ac_Suffix_NAME = D.Suffix_NAME,
               @An_MemberSsn_NUMB = D.MemberSsn_NUMB,
               @Ad_Birth_DATE = D.Birth_DATE,
               @Ac_Restricted_INDC = D.Restricted_INDC,
               @Ac_StatusLocate_CODE = L.StatusLocate_CODE,
               @Ac_FamilyViolence_INDC = ISNULL((SELECT TOP 1 C1.FamilyViolence_INDC
                                            FROM CMEM_Y1 C1
                                           WHERE C1.MemberMci_IDNO = @An_MemberMci_IDNO
                                           AND C1.FamilyViolence_INDC = @Lc_Yes_INDC), @Lc_No_INDC)
    FROM DEMO_Y1 D
         LEFT OUTER JOIN LSTT_Y1 L
          ON L.MemberMci_IDNO = D.MemberMci_IDNO
             AND L.EndValidity_DATE = @Ld_High_DATE
   WHERE D.MemberMci_IDNO = @An_MemberMci_IDNO;
 END; -- End of DEMO_RETRIEVE_S45

GO
