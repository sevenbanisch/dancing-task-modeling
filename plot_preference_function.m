function plot_preference_function(delta, deltarange, dMax, mode)
    if nargin < 1
        delta = 8;
    end
    if nargin < 2
        deltarange = 5.5;
    end
    if nargin < 3
        dMax = 22;
    end
    if nargin < 4
        mode = "exp";
    end
    
    d = linspace(0, dMax, 2000);
    
    xi = 0;
    r = arrayfun(@(dj) preference(xi, dj, delta, deltarange, mode), d);
    
    figure(2)
    plot(d, r, 'LineWidth', 2);
    xlabel('|xi - xj|'); ylabel('reward'); title('Preference function');
    xline(delta, '--', 'preferred distance'); grid on;
    xlim([0, dMax])
end

% figure(3)
% % Preference R(xi,xj) on discrete positions 1..9
% delta = 2; 
% deltarange = 1;                % tolerance/width
% vals = 1:9;
% [Xi,Xj] = meshgrid(vals, vals);
% 
% % Using your preference() function
% R = arrayfun(@(a,b) preference(a,b,delta,deltarange), Xi, Xj);
% 
% % Heat map
% imagesc(vals, vals, R); set(gca,'YDir','normal');
% axis square; colorbar
% xlabel('x_i'); ylabel('x_j'); title('Preference R(x_i,x_j)');
% xticks(vals); yticks(vals);
% 
% % (Optional) 3D surface
% figure; surf(Xi, Xj, R); shading interp
% xlabel('x_i'); ylabel('x_j'); zlabel('reward'); title('Preference surface');