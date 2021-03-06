/****** Object:  StoredProcedure [dbo].[CPTB_RETRIEVE_S5]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CPTB_RETRIEVE_S5] (
 @An_TransHeader_IDNO       NUMERIC(12, 0),
 @Ac_IVDOutOfStateFips_CODE CHAR(2),
 @Ad_Transaction_DATE       DATE,
 @An_MemberMci_IDNO         NUMERIC(10, 0) OUTPUT,
 @Ac_Last_NAME              CHAR(20) OUTPUT,
 @Ac_First_NAME             CHAR(16) OUTPUT,
 @Ac_Middle_NAME            CHAR(20) OUTPUT,
 @Ac_Suffix_NAME            CHAR(4) OUTPUT
 )
AS
 /*    
  *     PROCEDURE NAME    : CPTB_RETRIEVE_S5    
  *     DESCRIPTION       : In ICOR Screen ICR Worklist - Referrals Screen Function , while Assigning existing Case id then ISIN Records needs to be Inserted.
                            This procedure used to take PETITIONER NAME for ISIN Insert.
  *     DEVELOPED BY      : IMP Team  
  *     DEVELOPED ON      : 02-SEP-2011    
  *     MODIFIED BY       :     
  *     MODIFIED ON       :     
  *     VERSION NO        : 1       
 */
 BEGIN
  DECLARE @Lc_Relationship_CODE CHAR(1) = 'C',
          @Li_One_NUMB          SMALLINT = 1;

  SELECT @An_MemberMci_IDNO = c.MemberMci_IDNO,
         @Ac_Last_NAME = c.Last_NAME,
         @Ac_First_NAME = c.First_NAME,
         @Ac_Middle_NAME = c.Middle_NAME,
         @Ac_Suffix_NAME = c.Suffix_NAME
    FROM (SELECT P.MemberMci_IDNO,
                 P.First_NAME,
                 P.Middle_NAME,
                 P.Last_NAME,
                 P.Suffix_NAME,
                 ROW_NUMBER () OVER (ORDER BY P.Blockseq_NUMB DESC) AS OrderBlockseq_NUMB
            FROM CPTB_Y1 P
           WHERE P.Relationship_CODE = @Lc_Relationship_CODE
             AND P.TransHeader_IDNO = @An_TransHeader_IDNO
             AND P.IVDOutOfStateFips_CODE = @Ac_IVDOutOfStateFips_CODE
             AND P.Transaction_DATE = @Ad_Transaction_DATE) c
   WHERE OrderBlockseq_NUMB = @Li_One_NUMB;
 END; --End of CPTB_RETRIEVE_S5    


GO
