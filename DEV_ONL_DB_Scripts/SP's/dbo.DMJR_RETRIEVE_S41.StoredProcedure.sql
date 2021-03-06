/****** Object:  StoredProcedure [dbo].[DMJR_RETRIEVE_S41]    Script Date: 4/10/2015 3:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DMJR_RETRIEVE_S41] (
 @An_Case_IDNO          NUMERIC(6),
 @An_MajorIntSeq_NUMB   NUMERIC(5),
 @An_OrderSeq_NUMB      NUMERIC(2) OUTPUT,
 @An_MemberMci_IDNO     NUMERIC(10) OUTPUT,
 @Ac_ActivityMajor_CODE CHAR(4) OUTPUT,
 @Ac_Subsystem_CODE     CHAR(2) OUTPUT,
 @An_OthpSource_IDNO    NUMERIC(10) OUTPUT,
 @Ad_Entered_DATE       DATE OUTPUT,
 @Ac_TypeReference_CODE CHAR(5) OUTPUT
 )
AS
 /*                                                                                                                         
  *     PROCEDURE NAME    : DMJR_RETRIEVE_S41                                                                               
  *     DESCRIPTION       : Retrieve Subsystem code, Major Activity code, Other party Source ID and Member ID for a Case ID.
  *     DEVELOPED BY      : IMP Team                                                                                        
  *     DEVELOPED ON      : 04-AUG-2011                                                                                     
  *     MODIFIED BY       :                                                                                                 
  *     MODIFIED ON       :                                                                                                 
  *     VERSION NO        : 1                                                                                               
  */
 BEGIN

  SELECT @An_OrderSeq_NUMB = d.OrderSeq_NUMB,
         @An_MemberMci_IDNO = d.MemberMci_IDNO,
         @Ac_ActivityMajor_CODE = d.ActivityMajor_CODE,
         @Ac_Subsystem_CODE = d.Subsystem_CODE,
         @An_OthpSource_IDNO = d.OthpSource_IDNO,
         @Ac_TypeReference_CODE = d.TypeReference_CODE,
         @Ad_Entered_DATE = d.Entered_DATE
    FROM DMJR_Y1 d
   WHERE d.Case_IDNO = @An_Case_IDNO
     AND d.MajorIntSeq_NUMB = @An_MajorIntSeq_NUMB;
 END; --End of DMJR_RETRIEVE_S41                                                                                           

GO
