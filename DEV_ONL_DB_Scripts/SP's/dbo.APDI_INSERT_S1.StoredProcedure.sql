/****** Object:  StoredProcedure [dbo].[APDI_INSERT_S1]    Script Date: 4/10/2015 3:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[APDI_INSERT_S1](
 @An_Application_IDNO  NUMERIC(15),
 @An_MemberMci_IDNO    NUMERIC(10),
 @An_DependantMci_IDNO NUMERIC(10),
 @Ac_MedicalIns_INDC   CHAR(1),
 @Ac_DentalIns_INDC    CHAR(1)
 )
AS
 /*                                                                                                                                                                               
 *     PROCEDURE NAME    : APDI_INSERT_S1                                                                                                                                         
  *     DESCRIPTION       : Inserts the insurance details for the member. 
  *     DEVELOPED BY      : IMP Team                                                                                                                                            
  *     DEVELOPED ON      : 02-NOV-2011                                                                                                                                           
  *     MODIFIED BY       :                                                                                                                                                       
  *     MODIFIED ON       :                                                                                                                                                       
  *     VERSION NO        : 1                                                                                                                                                     
 */
 BEGIN
  INSERT INTO APDI_Y1
              (Application_IDNO,
               MemberMci_IDNO,
               DependantMci_IDNO,
               MedicalIns_INDC,
               DentalIns_INDC)
       VALUES (@An_Application_IDNO,
               @An_MemberMci_IDNO,
               @An_DependantMci_IDNO,
               @Ac_MedicalIns_INDC,
               @Ac_DentalIns_INDC );
 END; --End of APDI_INSERT_S1

GO
