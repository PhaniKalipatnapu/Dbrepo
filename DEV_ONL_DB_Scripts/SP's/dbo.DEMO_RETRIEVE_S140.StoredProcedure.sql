/****** Object:  StoredProcedure [dbo].[DEMO_RETRIEVE_S140]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DEMO_RETRIEVE_S140] ( 
 @An_MemberMci_IDNO        NUMERIC(10), 
 @Ac_BirthCertificate_ID   CHAR(20) OUTPUT
 )
AS
 /*                                                                                                                                                               
   *     PROCEDURE NAME    : DEMO_RETRIEVE_S140                                                                                                                        
   *     DESCRIPTION       : Retrieves the Birth Certificate number of the respective member.                                                                                                 
   *     DEVELOPED BY      : IMP Team  
   *     DEVELOPED ON      : 16-MAY-2012                                                                                                                           
   *     MODIFIED BY       :                                                                                                                                       
   *     MODIFIED ON       :                                                                                                                                       
   *     VERSION NO        : 1                                                                                                                                     
  */
 BEGIN
  SELECT @Ac_BirthCertificate_ID = M.BirthCertificate_ID         
    FROM DEMO_Y1 D
         LEFT OUTER JOIN MPAT_Y1 M
          ON (D.MemberMci_IDNO = M.MemberMci_IDNO)
         JOIN CMEM_Y1 C
          ON (D.MemberMci_IDNO = C.MemberMci_IDNO)
   WHERE D.MemberMci_IDNO = @An_MemberMci_IDNO;         
 END; -- End Of DEMO_RETRIEVE_S140                                                                                                                

GO
