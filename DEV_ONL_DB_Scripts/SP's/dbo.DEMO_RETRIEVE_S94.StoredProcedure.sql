/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S94]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S94] (
 @An_MemberMci_IDNO      NUMERIC(10, 0),
 @Ac_Last_NAME           CHAR(20) OUTPUT,
 @Ac_First_NAME          CHAR(16) OUTPUT,
 @Ac_Middle_NAME         CHAR(20) OUTPUT,
 @An_MemberSsn_NUMB      NUMERIC(9, 0) OUTPUT,
 @Ad_Birth_DATE          DATE OUTPUT,
 @Ad_Deceased_DATE          DATE OUTPUT,
 @Ac_FamilyViolence_INDC CHAR(1) OUTPUT
 )
AS
 /*    
  *     PROCEDURE NAME    : DEMO_RETRIEVE_S94    
  *     DESCRIPTION       : Retrieving Member Details.    
  *     DEVELOPED BY      : IMP Team    
  *     DEVELOPED ON      : 12-AUG-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1    
 */
 BEGIN
  SELECT @Ac_FamilyViolence_INDC = NULL,
		 @Ad_Deceased_DATE = NULL,
         @Ad_Birth_DATE = NULL,
         @An_MemberSsn_NUMB = NULL,
         @Ac_Last_NAME = NULL,
         @Ac_First_NAME = NULL,
         @Ac_Middle_NAME = NULL;

  DECLARE @Lc_Yes_INDC  CHAR(1) = 'Y',
		  @Lc_No_INDC   CHAR(1) = 'N',
          @Ld_High_DATE DATE = '12/31/9999';

  SELECT TOP 1 @Ac_Last_NAME = D.Last_NAME,
               @Ac_First_NAME = D.First_NAME,
               @Ac_Middle_NAME = D.Middle_NAME,
               @An_MemberSsn_NUMB = D.MemberSsn_NUMB,
               @Ad_Birth_DATE = D.Birth_DATE,
               @Ad_Deceased_DATE = D.Deceased_DATE, 
               @Ac_FamilyViolence_INDC = ISNULL((SELECT TOP 1 C1.FamilyViolence_INDC
                                            FROM CMEM_Y1 C1
                                           WHERE C1.MemberMci_IDNO = @An_MemberMci_IDNO
                                           AND C1.FamilyViolence_INDC = @Lc_Yes_INDC), @Lc_No_INDC)
    FROM DEMO_Y1 D
   WHERE D.MemberMci_IDNO = @An_MemberMci_IDNO;
 END; -- End of DEMO_RETRIEVE_S94

GO
