using Bernhoeft.GRT.Core.EntityFramework.Domain.Interfaces;
using Bernhoeft.GRT.Core.Interfaces.Results;
using Bernhoeft.GRT.Core.Models;
using Bernhoeft.GRT.Teste.Application.Requests.Commands.v1;
using Bernhoeft.GRT.Teste.Application.Responses.Commands.v1;
using Bernhoeft.GRT.Teste.Domain.Entities;
using Bernhoeft.GRT.Teste.Domain.Interfaces.Repositories;
using MediatR;
using Microsoft.Extensions.DependencyInjection;

namespace Bernhoeft.GRT.Teste.Application.Handlers.Commands.v1
{
    public class CreateAvisoHandler : IRequestHandler<CreateAvisoRequest, IOperationResult<CreateAvisoResponse>>
    {
        private readonly IServiceProvider _serviceProvider;
        private IContext _context => _serviceProvider.GetRequiredService<IContext>();
        private IAvisoRepository _avisoRepository => _serviceProvider.GetRequiredService<IAvisoRepository>();

        public CreateAvisoHandler(IServiceProvider serviceProvider) => _serviceProvider = serviceProvider;

        public async Task<IOperationResult<CreateAvisoResponse>> Handle(CreateAvisoRequest request, CancellationToken cancellationToken)
        {
            var aviso = new AvisoEntity
            {
                Titulo = request.Titulo,
                Mensagem = request.Mensagem,
                Ativo = true,
                CriadoEm = DateTime.UtcNow
            };

            await _avisoRepository.AddAsync(aviso, CancellationToken.None);
            await _context.SaveChangesAsync(CancellationToken.None);

            return OperationResult<CreateAvisoResponse>.ReturnOk((CreateAvisoResponse)aviso);
        }
    }
}